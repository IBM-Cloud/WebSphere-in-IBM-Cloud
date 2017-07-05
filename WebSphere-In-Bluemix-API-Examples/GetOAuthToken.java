// Licensed under the Apache License. See footer for details.
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

import javax.xml.bind.DatatypeConverter;

// Retrieve your OAuth token needed to use this API.
public class GetOAuthToken {
	/* WebSphere Application Server for Bluemix API URL. 
	 * The access token returned from this call will only work for the environment URL you generate it with.
	 * 
	 * Available Environments:
	 * Dallas - https://wasaas-broker.ng.bluemix.net/wasaas-broker/api/v1
	 * London - https://wasaas-broker.eu-gb.bluemix.net/wasaas-broker/api/v1
	 * Sydney - https://wasaas-broker.au-syd.bluemix.net/wasaas-broker/api/v1
	 */
	private static final String apiEndpoint = "https://wasaas-broker.ng.bluemix.net/wasaas-broker/api/v1";

	public static void main(String[] args) throws IOException{		
		// Use TLSv1.2
		System.setProperty("https.protocols", "TLSv1.2");
		
		String bluemixUsername = "<YOUR_USERNAME>";
		String bluemixPassword = "<YOUR_PASSWORD>";
		
		// Create the Basic auth string.
		String authStr = bluemixUsername + ":" + bluemixPassword;
		// Base64 Encode the username and password.
		String authEncoded = DatatypeConverter.printBase64Binary(authStr.getBytes());
		
		// Create the URL.
		URL oauthURL = new URL(apiEndpoint + "/oauth");
		HttpURLConnection con = (HttpURLConnection) oauthURL.openConnection();
		con.setRequestMethod("GET");
		con.setRequestProperty("Authorization", "Basic " + authEncoded);

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