# WebSphere Application Server in Bluemix

IBM [WebSphere Application Server in Bluemix][https://console-regional.ng.bluemix.net/docs/services/ApplicationServeronCloud/index.html] is a service in Bluemix that facilitates quick setup on a pre-configured WebSphere Application Server Liberty, Traditional Network Deployment, or Traditional WebSphere instance in a hosted cloud environment.

WebSphere Application Server in Bluemix provides consumers with pre-configured Traditional WebSphere and Liberty Profile servers. It is hosted on virtual machine guests with root access to the guest operating system. When you are creating your service, choose between Liberty, Traditional ND, or Traditional WebSphere.

You can create and manage this service in 2 ways

  1. In your browser by creating an instance via the [Bluemix Catalog][https://console.bluemix.net/catalog/services/websphere-application-server/]
  1. Programatically using the WebSphere Application Server in Bluemix *API*

The example code in the WebSphere-In-Bluemix-API-Examples folder contains Java code that utilizes the API to perform tasks such as:

  * Create a service instance.
  * Read credentials for your machine.
  * Start / Stop your machine.
  * Delete a service instance
  * And more...
  
The example code in the Scaling-Service-Example folder contains a script that utilizes the API to perform tasks such as:
  
  * Review resources running within a service instance
  * Start desired number of nodes within a service instance
  * Stop desired number of nodes within a service instance
 
