# Scaling Service Example Script

This script allows consumers to manage the different resources otherwise referred to as "nodes" within their specific service instances. Consumers are able to specify the exact number of nodes they want running within a cell, and the script automatically starts and stops the nodes in order to meet their specifications.

This script can be used in conjunction with a cron job to start an appropriate workload during the morning and scale it back down at the end of the day. Using a Pay as You Go instance, the consumer would only pay 5% of the Pay as You Go while the guests were stopped.

## Running the Script

* Populate Required Fields
  * The following fields must be populated in order to run the script
      1. HOST         (Example: https://wasaas-broker.us-south.websphereappsvr.cloud.ibm.com/wasaas-broker/api/v1)                 
      2. ORGANIZATION (Example: johndoe@ibm.com)          
      3. SPACE        (Example: dev)           
      4. BASIC_AUTH   (Example: Basic 99dj9jf9u7f77f7f7hwh3u4hjjnjk)         
      5. SERVICE_INSTANCE_ID   (Example: dc8djk2-ddbf-43n33-ba4e-132094dn3imd)
      6. DESIRED_NODES_RUNNING (Example: 4)

* Verify that execute permissions are enabled on the script
  * If execute permissions are not enabled run `chmod 755 ScaleService.sh`

* Run the script by executing `./ScaleService.sh`

## Documentation
This script was written with reusability and enhancement in mind. All documentation for the script is located within the ScaleService.sh file.
