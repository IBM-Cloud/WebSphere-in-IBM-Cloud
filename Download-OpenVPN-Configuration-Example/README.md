# Download OpenVPN configuration Example Script

This script allows consumers to download a configuration document for OpenVPN client access.

## Running the Script

* Populate Required Fields
  * The following fields must be populated in order to run the script
      1. HOST         (Example: https://wasaas-broker.us-south.websphereappsvr.cloud.ibm.com/wasaas-broker/api/v1)
      2. ORGANIZATION (Example: johndoe@ibm.com)
      3. SPACE        (Example: dev)
      4. SERVICE_INSTANCE_ID   (Example: dc8djk2-ddbf-43n33-ba4e-132094dn3imd)

  * Authentication. Either set BASIC_AUTH
      (5). BASIC_AUTH   (Example: Basic 99dj9jf9u7f77f7f7hwh3u4hjjnjk)         
      OR for federated ids use single use passcode on commandline.  Get one using browser from
      E.g. https://identity-1.us-south.iam.cloud.ibm.com/identity/passcode

* Verify that execute permissions are enabled on the script
  * If execute permissions are not enabled run `chmod 755 ScaleService.sh`

* Run the script by executing `./DownloadVpnCfg.sh [passcode]`

## Documentation
This script was written with reusability and enhancement in mind. All documentation for the script is located within the DownloadVpnCfg.sh file.
