#!/bin/bash 
#
#  Copyright IBM Corp. 2016-2017
#  All rights reserved.
#  US Government Users Restricted Rights -
#  Use, duplication or disclosure restricted
#  by GSA ADP Schedule Contract with IBM Corp.
#
#  Licensed Materials-Property of IBM
#
########################################################################################
# Name:             DownloadVPNCfg.sh
#
# Description:      This script will fetch an OpenVPN configuration document 
#                   suitable for connecting to your VMs.
#
# Instructions:     Run this script by executing ./DownloadVPNCfg.sh after
#                   populating the properties file with all of the necessary information
#
# Dependent Files:  These files are needed by the script
#                       * DownloadVPN.properties (Should be co-located with this script)
#
# Author:           Brian Sullivan
#
# Last Update:      11/29/2017
########################################################################################
help() {
   cat <<EOF
Usage: `basename $0` [passcode]
Notes: Non-federated IDs will authenticate using the BASIC_AUTH credential set in the 
associated properties file.
For federated ID authentication, don't set BASIC_AUTH in properties file.
Instead, obtain a single use passcode and place it on the commandline.  The
single use passcode may be acquired from the showpasscode.jsp via browser.  E.g.,
https://login.ng.bluemix.net/UAALoginServerWAR/showpasscode.jsp
EOF
exit
}

################# Get Bearer Token Function #####################
# This function retrieves the Bearer Token that is used in order
# to access the WASaaS Broker API
#
# Parameters: None
#################################################################
get_bearer_token() {
   curl -s -X GET \
      -H "Authorization: $BASIC_AUTH" \
      -H "Accept: application/json" \
      -H "Cache-control: no-cache" \
      "$HOST"/oauth > CurrentBearerToken.txt
}

############### Get SSO Bearer Token Function ###################
# This function retrieves the Bearer Token that is used in order
# to access the WASaaS Broker API for federated Ids.
#
# Parameters: None
#################################################################
get_SSO_bearer_token() {
   curl -s -X GET \
      -H "Authorization: SSO $PASSCODE" \
      -H "Accept: application/json" \
      -H "Cache-control: no-cache" \
      "$HOST"/oauth >CurrentBearerToken.txt
}

############### Set Bearer Token Function #######################
# This function retrieves the Bearer Token that is used in order
# to access the WASaaS Broker API for federated Ids.
#
# Parameters: None
#################################################################
set_bearer_token() {
   if [ "$BASIC_AUTH" = "" ]
   then
      get_SSO_bearer_token
   else
      get_bearer_token
   fi
   BEARERTOKEN=$(head CurrentBearerToken.txt | grep -E -o '"access_token":".*' | cut -f4 -d\")
   rm CurrentBearerToken.txt
}

############## Get OpenVPN configuration file ###################
# This function retrieves the OpenVPN configuration file.
# to access the WASaaS private network via vpn.
#
# Parameters: None
#################################################################
get_OpenVPN_file() {
   curl -s -X GET \
       "$HOST"/organizations/"$ORGANIZATION"/spaces/"$SPACE"/serviceinstances/"$SERVICE_INSTANCE_ID"/vpnconfig \
       -H "Accept: text/plain" \
       -H "Authorization: Bearer $BEARERTOKEN" \
       -H "Cache-control: no-cache" --remote-name --remote-header-name
}

##################################################################
# Main Function Start
##################################################################

# source properties
. DownloadVpnCfg.properties

# validate inputs
if [ $# -eq "1" ]
then
   PASSCODE=$1
elif [ "$BASIC_AUTH" = "" ]
then
   help
fi

# Logon
set_bearer_token

# Fetch ovpn
get_OpenVPN_file

