// Licensed under the Apache License. See footer for details.
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

// Create a service instance.
public class CreateServiceInstance {
	/* WebSphere Application Server for IBM Cloud API URL.
	 * Available Environments:
	 * Dallas - https://wasaas-broker.us-south.websphereappsvr.cloud.ibm.com/wasaas-broker/api/v1
	 * London - https://wasaas-broker.eu-gb.websphereappsvr.cloud.ibm.com/wasaas-broker/api/v1
	 * Sydney - https://wasaas-broker.au-syd.websphereappsvr.cloud.ibm.com/wasaas-broker/api/v1
	 * Frankfurt - https://wasaas-broker.eu-de.websphereappsvr.cloud.ibm.com/wasaas-broker/api/v1
	 */
	
	private static final String apiEndpoint = "https://wasaas-broker.us-south.websphereappsvr.cloud.ibm.com/wasaas-broker/api/v1";

	public static void main(String[] args) throws IOException{
		// You can see how to get your access token from GetOAuthToken sample class.
		String accessToken = "<YOUR_ACCESS_TOKEN>";
		// The IBM Cloud organization & space to query - case sensitive.
		String org = "<YOUR_ORG>"; // Example: johndoe@ibm.com
		String space = "<YOUR_SPACE>"; // Example: dev 

		// Use TLSv1.2.
		System.setProperty("https.protocols", "TLSv1.2");

		// Create the URL.
		URL orgsURL = new URL(apiEndpoint + "/organizations/" + org + "/spaces/" + space + "/serviceinstances");
		HttpURLConnection con = (HttpURLConnection) orgsURL.openConnection();
		con.setRequestMethod("POST");
		con.setRequestProperty("Authorization", "Bearer " + accessToken);
		con.setRequestProperty("Content-Type","application/json");
		con.setDoOutput(true);

		/* CREATE OPTIONS
		 * Type:                    The plan type to create.
		 * 							Enum: ["LibertyCollective", "LibertyCore", "LibertyNDServer", "WASBase", "WASCell", "WASNDServer"]
		 *
		 * Name:                    Name your new service icon in IBM Cloud.
		 *
		 * ApplicationServerVMSize: The size of the virtual machine.
		 * 							Enum: [S, M, L, XL, XXL]
		 *
		 * ControlServerVMSize:     The size of the Virtual Machine containing the Collective Controller for a LibertyCollective service instance,
		 * 							or the size of the Virtual Machine containing the DMGR for a WASCell service instance. This is required for
		 * 						 	types "LibertyCollective" and "WASCell", Illegal argument for the other Types.
		 * 							Enum: [S, M, L, XL, XXL]
		 *
		 * NumberOfApplicationVMs:  The number (integer) of application server Virtual Machines to create This is required for types "LibertyCollective"
		 * 							and "WASCell", Illegal argument for the other Types.
		 *
		 * Software_Level:          This is optional for types "WASBase", "WASNDServer", and "WASCell". If one is not specified version "9.0.0" will be default.
		 * 							Enum: ["8.5.5", "9.0.0"]
		 */
		String createOptionsJSON = "{\"Type\":\"LibertyCore\",\"Name\":\"MyFirstAPIServiceInstance\",\"ApplicationServerVMSize\":\"S\"}";

		// Add JSON POST data.
		DataOutputStream wr = new DataOutputStream(con.getOutputStream());
		wr.writeBytes(createOptionsJSON);
		wr.flush();
		wr.close();

		BufferedReader br = null;
		if (HttpURLConnection.HTTP_OK == con.getResponseCode()) {
			br = new BufferedReader(new InputStreamReader(con.getInputStream()));
		}
		else {
			br = new BufferedReader(new InputStreamReader(con.getErrorStream()));
		}

		StringBuffer response = new StringBuffer();
		String line;

		while ((line = br.readLine()) != null) {
			response.append(line);
		}
		br.close();

		// Response from the request.
		System.out.println(response.toString());

		/* Example Response for creating a service instance of type "LibertyCore"
		 * {
		 * 	"Status":"Active",
		 * 	"ApplicationVMInfo":
		 * 	{
		 * 		"disk":12.0,
		 * 		"memory":2048,"vcpu":1
		 * 	},
		 * 	"ServiceInstance":
		 * 	{
		 * 		"ServiceInstanceID":"8b80bac5-4e78-4a87-bb3e-0e4a8fd6d13a",
		 * 		"ServiceType":"LibertyCore",
		 * 		"SpaceID":"esw7jc13-b12a-47jn-9627-06jdu78d98ed",
		 * 		"OrganizationID":"a23w6701-5324-4af8-b593-e9fdffer36a2",
		 * 		"Name":"MyFirstAPIServiceInstance"
		 * 	}
		 * }
		 */
	}

}
//    ------------------------------------------------------------------------------
//     Licensed under the Apache License, Version 2.0 (the "License");
//     you may not use this file except in compliance with the License.
//     You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
//     Unless required by applicable law or agreed to in writing, software
//     distributed under the License is distributed on an "AS IS" BASIS,
//     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//     See the License for the specific language governing permissions and
//     limitations under the License.
//    ------------------------------------------------------------------------------
