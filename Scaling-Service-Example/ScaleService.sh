#!/usr/bin/env bash -e
#
#  Copyright IBM Corp. 2016-2017
#  All rights reserved.
#  US Government Users Restricted Rights -
#  Use, duplication or disclosure restricted
#  by GSA ADP Schedule Contract with IBM Corp.
#
#  Licensed Materials-Property of IBM
#
####################################################################################################
# Name:             ScaleService.sh
#
# Description:      This script will automatically scale nodes by starting or stopping them for the customer
#
# Instructions:     Run this script via cron or a terminal by executing ./ScaleService.sh after
#                   populating the properties file with all of the necessary information
#
# Dependencies:     Script needs 'jq' installed in order to run. Can be downloaded by executing
#                   'brew install jq', 'sudo apt-get install jq', 'sudo yum install jq'
#
# Dependent Files:  These files are needed by the script
#                       * ScaleService.properties (Should be co-located with this script)
#
# Author:           Kamran Rana
#
# Last Update:      06/29/2017
####################################################################################################


################# Get Bearer Token Function #####################
# This function retrieves the Bearer Token that is used in order
# to access the WasaaS Broker API
#
# Parameters: None
#################################################################
get_bearer_token() {

   curl -s -X GET --header "Accept: application/json" --header "authorization: $BASIC_AUTH" "$HOST"/oauth > CurrentBearerToken.txt

   BearerTokenTemp=$(head CurrentBearerToken.txt | grep -E -o '"access_token":".*' | cut -f4 -d\")
   BearerToken="Bearer $BearerTokenTemp"
   rm CurrentBearerToken.txt
}


################ Get Active Instances Function ###################
# This function retrieves the instances that are currently
# "RUNNING" and the instances that are currently in the "STOPPED"
# state. It displays the name of the instance in the cell, along
# with the Resource ID of the specific instance
#
# Parameters: $1 - Text file with resource instance information
#             $2 - Number of resource instances
##################################################################
get_active_instances() {

   RunningInstancesArray=()
   StoppedInstancesArray=()
   Counter=0

   while [[ "$Counter" -lt "$2" ]]; do
      MachineStatus=$(cat "$1" | jq .["$Counter"].machinestatus | cut -f2 -d \")
      MachineID=$(cat "$1" | jq .["$Counter"].WASaaSResourceID | cut -f2 -d \")
      MachineName=$(cat "$1" | jq .["$Counter"].machinename | cut -f2 -d \")
      Instance=$(printf "%-60s%11s%30s\n" "$MachineName" "ID: " "$MachineID") #Specifies the format of the instance output
      if [ "$MachineStatus" == "RUNNING" ]; then
         RunningInstancesArray+=("$Instance")
      else
         StoppedInstancesArray+=("$Instance")
      fi
      let Counter=Counter+1
   done

   echo ""
   echo "Instances currently running"
   echo --------------------------------------------------------
   printf '%s\n' "${RunningInstancesArray[@]}"
   echo ""
   echo "Instances currently stopped"
   echo --------------------------------------------------------
   printf '%s\n' "${StoppedInstancesArray[@]}"
   echo ""
}


####################### Scale Function ###########################
# This function determines whether to scale the number of nodes
# in the cell up or down. It calculates the number of nodes that
# need to be powered up or down, and then calls the appropriate
# function to carry out the starting or stopping
#
# Parameters: $1 - "up" if we want to spin up instances or "down"
#                  if we want to scale down by stopping instances
##################################################################
scale() {

   NodesToScale=0

   if [[ "$1" == "up" ]]; then
      let NodesToScale="$DESIRED_NODES_RUNNING"-"${#RunningInstancesArray[@]}"
      echo "Scaling service up, starting $NodesToScale instance(s)"
      start_instances "$NodesToScale"
   else
      let NodesToScale="${#RunningInstancesArray[@]}"-"$DESIRED_NODES_RUNNING"
      echo "Scaling service down, stopping $NodesToScale instance(s)"
      stop_instances "$NodesToScale"
   fi
}


################### Start Instances Function #####################
# This function starts the desired number of instances passed in
# to the function. The function looks at the instances that are
# currently "STOPPED" and then starts however many of them using
# the WasaaS Broker API
#
# Parameters: $1 - The number of instances to start
##################################################################
start_instances() {

   NodesScaled=0

   while [[ "$NodesScaled" -lt "$1" ]]; do
      Resource_ID=$(echo "${StoppedInstancesArray[$NodesScaled]}" | grep ': ' | sed 's/^.*: //')
      curl -s -X PUT --header "Accept: application/json" --header "authorization: $BearerToken" "$HOST"/organizations/"$ORGANIZATION"/spaces/"$SPACE"/serviceinstances/"$SERVICE_INSTANCE_ID"/resources/"$Resource_ID"?action=start > StartStatus.txt

      # Make sure to check error status codes
      if grep -E -q "HTTP/1.1 404 Not Found" StartStatus.txt ; then
         echo "Unable to find resource. Make sure the Organization, Space and ServiceInstanceID are correct"
         echo "Check StartStatus.txt for more information"
         exit 1
      elif grep -E -q "HTTP/1.1 401 Unauthorized" StartStatus.txt ; then
         echo "Authorization error, check your authentication tokens"
         echo "Check StartStatus.txt for more information"
         exit 1
      elif grep -E -q "HTTP/1.1 301 Moved Permanently" StartStatus.txt ; then
         echo "Error, protocal other than HTTPS used"
         echo "Check StartStatus.txt for more information"
         exit 1
      fi

      Status=$(tail -1 StartStatus.txt | jq .Status | cut -f2 -d \")

      # Make sure that our PUT request returned an Ok back
      if [[ "$Status" != "Ok" ]]; then
         echo "Machine $Resource_ID failed to start. Check StartStatus.txt file for more information. Exiting..."
         exit 1
      fi

      rm StartStatus.txt
      echo "Starting instance $Resource_ID (This will take a few minutes)"
      poll_if_running "$Resource_ID"
      let NodesScaled=NodesScaled+1
   done
}


#################### Stop Instances Function ######################
# This function stops the desired number of instances passed in
# to the function. The function looks at the instances that are
# currently "RUNNING" and then stops however many of them using
# the WasaaS Broker API. The function, however, does not allow
# for the manager node inside of the cell.
#
# Parameters: $1 - The number of instances to stop
##################################################################
stop_instances() {
   NodesScaled=0

   while [[ "$NodesScaled" -le "$1" ]]; do
      if [[ "${RunningInstancesArray[$NodesScaled]}" == *"DM"* ]]; then
         let NodesScaled=NodesScaled+1
         continue
      fi

      Resource_ID=$(echo "${RunningInstancesArray[$NodesScaled]}" | grep ': ' | sed 's/^.*: //')
      curl $CurlFlags -X PUT --header "Accept: application/json" --header "authorization: $BearerToken" "$HOST"/organizations/"$ORGANIZATION"/spaces/"$SPACE"/serviceinstances/"$SERVICE_INSTANCE_ID"/resources/"$Resource_ID"?action=stop > StopStatus.txt

      # Make sure to check error status codes
      if grep -E -q "HTTP/1.1 404 Not Found" StopStatus.txt ; then
         echo "Unable to find resource. Make sure the Organization, Space and ServiceInstanceID are correct"
         echo "Check StopStatus.txt for more information"
         exit 1
      elif grep -E -q "HTTP/1.1 401 Unauthorized" StopStatus.txt ; then
         echo "Authorization error, check your authentication tokens"
         echo "Check StopStatus.txt for more information"
         exit 1
      elif grep -E -q "HTTP/1.1 301 Moved Permanently" StopStatus.txt ; then
         echo "Error, protocal other than HTTPS used"
         echo "Check StopStatus.txt for more information"
         exit 1
      fi

      Status=$(tail -1 StopStatus.txt | jq .Status | cut -f2 -d \")

      if [[ "$Status" != "Ok" ]]; then
         echo "Machine $Resource_ID could not be stopped. Check StopStatus.txt file for more information. Exiting..."
         exit 1
      fi

      rm StopStatus.txt
      echo "Stopping instance $Resource_ID (This will take a few minutes)"
      poll_if_stopped "$Resource_ID"
      let NodesScaled=NodesScaled+1
   done
}


#################### Poll If Running Function #####################
# This function polls the Resource ID specified in the parameter
# in order to check to see if the resource has changed from the
# "STOPPED" state to the "RUNNING" state. This function allows
# 15 minutes for an instance to start up, otherwise it times out
#
# Parameters: $1 - The instance to poll
##################################################################
poll_if_running() {

   CurrMin=1
   MaxMin=15 #We will loop up to 15 mins to check if an instance is up and running

   while [[ "$CurrMin" -le "$MaxMin" ]]; do
      curl $CurlFlags -X GET --header "Accept: application/json" --header "authorization: $BearerToken" "$HOST"/organizations/"$ORGANIZATION"/spaces/"$SPACE"/serviceinstances/"$SERVICE_INSTANCE_ID"/resources/"$1" > ResourceStatus.txt
      MachineStatus=$(tail -1 ResourceStatus.txt | jq .machinestatus | cut -f2 -d \")

      if [[ "$MachineStatus" == "RUNNING" ]]; then
         echo "Instance $1 started in $CurrMin minutes!"
         rm ResourceStatus.txt
         break
      else
         if [[ "$CurrMin" -eq "$MaxMin" ]]; then
            echo "Tried for $MaxMin minutes to start instance $1. Instance is taking too long to spin up"
            echo "Look at ResourceStatus.txt for more information on the issue"
            exit 1
         fi
         let CurrMin=CurrMin+1
         sleep 60
      fi
   done
}


#################### Poll If Stopped Function ####################
#
#
#
# Parameters: $1 - The instance to poll
##################################################################
poll_if_stopped() {

   CurrMin=1
   MaxMin=15 #We will loop up to 15 mins to check if an instance has stopped

   while [[ "$CurrMin" -le "$MaxMin" ]]; do
      curl $CurlFlags -X GET --header "Accept: application/json" --header "authorization: $BearerToken" "$HOST"/organizations/"$ORGANIZATION"/spaces/"$SPACE"/serviceinstances/"$SERVICE_INSTANCE_ID"/resources/"$1" > ResourceStatus.txt
      MachineStatus=$(tail -1 ResourceStatus.txt | jq .machinestatus | cut -f2 -d \")

      if [[ "$MachineStatus" == "STOPPED" ]]; then
         echo "Instance $1 stopped in $CurrMin minutes!"
         rm ResourceStatus.txt
         break
      else
         if [[ "$CurrMin" -eq "$MaxMin" ]]; then
            echo "Tried for $MaxMin minutes to stop instance $1. Instance is taking too long to spin down"
            echo "Look at ResourceStatus.txt for more information on the issue"
            exit 1
         fi
         let CurrMin=CurrMin+1
         sleep 60
      fi
   done
}


##################################################################
# Main Function Start
##################################################################

# Before we execute the script, we need to make sure that jq utility is installed
export JQ=$(command -v jq)
if [[ -z "$JQ" ]]; then
   echo "The jq utility has not been installed. Please read the script description and install jq."
   exit 1
fi

echo "========================================================"
echo "         Welcome to the WASaaS Scaling Script"
echo "========================================================"
echo ""
echo "This script will perform the following actions:"
echo ""
echo "* List the nodes that are currently running "
echo "* List the nodes that are currently stopped"
echo "* Scale the service to the desired number of nodes"
echo "* List nodes that have been started/stopped"
echo ""
echo --------------------------------------------------------
echo "Begin ScaleService.sh - "$(date)
echo --------------------------------------------------------

# Import variables from properties file
. ScaleService.properties
echo "Host URL: $HOST"
echo ""
# Set other variables for use in script
CurlFlags="-k -i -s"  # -k for ssl ignoring, -i for header info, -s for silent mode

# Retrieve Bearer Token from Bluemix to use API
echo "Retrieving bearer token..."
echo ""
get_bearer_token
echo "Your bearer token is: $BearerToken"
echo ""
echo "Retrieving resource instance information..."

# Retrieve all service instances
curl $CurlFlags -X GET --header "Accept: application/json" --header "authorization: $BearerToken" "$HOST"/organizations/"$ORGANIZATION"/spaces/"$SPACE"/serviceinstances/"$SERVICE_INSTANCE_ID"/resources > ResourcesLog.txt

# Make sure to check error status codes
if grep -E -q "HTTP/1.1 404 Not Found" ResourcesLog.txt ; then
   echo "Resources not found for ServiceInstanceID. Make sure the Organization, Space and ServiceInstanceID are correct"
   echo "Check resources log for error information"
   exit 1
elif grep -E -q "HTTP/1.1 401 Unauthorized" ResourcesLog.txt ; then
   echo "Authorization error, check your authentication tokens"
   echo "Check resources log for error information"
   exit 1
elif grep -E -q "HTTP/1.1 301 Moved Permanently" ResourcesLog.txt ; then
   echo "Error, protocal other than HTTPS used"
   echo "Check resources log for error information"
   exit 1
fi

# If we reach here, call 200 OK. Check number of resources provisioned
NumResources=$(tail -1 ResourcesLog.txt | jq '. | length')

# Make sure correct amount of nodes are being requested to be turned on/off
if [[ "$DESIRED_NODES_RUNNING" -gt "$NumResources" ]]; then
   echo "Error, you do not have enough resources to have $DESIRED_NODES_RUNNING nodes running"
   echo "Check service plan and ServiceInstanceID"
   exit 1
fi

# Make sure we at least have the manager node running
if [[ "$DESIRED_NODES_RUNNING" -lt 1 ]]; then
   echo "Error, you must have at least one manager node running"
   echo "Reconfigure desired amount of nodes in properties file and try again"
   exit 1
fi

# Dump resource instance info into file in JSON format
tail -1 ResourcesLog.txt | jq . > Resources.txt
rm ResourcesLog.txt

# Retrieve specific info about the active instances running
get_active_instances Resources.txt "$NumResources"
rm Resources.txt

# Check if we have to start or stop instances
if [[ "${#RunningInstancesArray[@]}" -gt "$DESIRED_NODES_RUNNING" ]] ; then
   scale "down"
elif [[ "${#RunningInstancesArray[@]}" -lt "$DESIRED_NODES_RUNNING" ]]; then
   scale "up"
else
   echo "You already have $DESIRED_NODES_RUNNING instance(s) running. Exiting..."
   exit 0
fi

# Retrieve all updated service instances
curl $CurlFlags -X GET --header "Accept: application/json" --header "authorization: $BearerToken" "$HOST"/organizations/"$ORGANIZATION"/spaces/"$SPACE"/serviceinstances/"$SERVICE_INSTANCE_ID"/resources > UpdatedResourcesLog.txt

# Dump updated resource info into file in JSON format
tail -1 UpdatedResourcesLog.txt | jq . > UpdatedResources.txt
rm UpdatedResourcesLog.txt

# List all of the updated resources now
echo ""
echo "Retrieving updated instance information..."
get_active_instances UpdatedResources.txt "$NumResources"
rm UpdatedResources.txt

#EOF
