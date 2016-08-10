# WebSphere Application Server for Bluemix API Usage Examples 

IBM [WebSphere Application Server for Bluemix][wasaas_docs_url] is a service on Bluemix that facilitates quick setup on a pre-configured WebSphere Application Server Liberty, Traditional Network Deployment, or Traditional WebSphere instance in a hosted cloud environment on Bluemix.

WebSphere Application Server for Bluemix provides consumers with pre-configured Traditional WebSphere and Liberty Profile servers. It is hosted on virtual machine guests with root access to the guest operating system. When you are creating your service, choose between Liberty, Traditional ND, or Traditional WebSphere.

You can create and manage this service in 2 ways

  1. In your browser by creating an instance via the [Bluemix Catalog][catalog_url]
  1. Programatically using the WebSphere Application Server for Bluemix *API*

The example code in this repository contains Java code that utilizes the API to perform tasks such as:

  * Create a service instance.
  * Read credentials for your machine.
  * Start / Stop your machine.
  * Delete a service instance
  * And more...

## Running the code

* Running In Eclipse

   1. Create a new Java Project in Eclipse

	1. Copy the `.java` files from this repository and paste into the `src` folder in your new Eclipse Java project.
	1. Right click the java class you want to run and select `Run As` -> `Java Application` 

## API documentation
These examples were built with developer reusability in mind. There is Swagger UI API Documentation available for reference. We have 3 different environments you can use.

* [USA (Dallas)][dallas_swagger_api_url]
* [UK (London)][london_swagger_api_url]
* [Australia (Sydney)][sydney_swagger_api_url]

[wasaas_docs_url]: https://new-console.ng.bluemix.net/docs/services/ApplicationServeronCloud/index.html
[catalog_url]: https://console.ng.bluemix.net/catalog/services/websphere-application-server/
[dallas_swagger_api_url]: https://wasaas-broker.ng.bluemix.net/wasaas-broker/api
[london_swagger_api_url]: https://wasaas-broker.eu-gb.bluemix.net/wasaas-broker/api
[sydney_swagger_api_url]: https://wasaas-broker.au-syd.bluemix.net/wasaas-broker/api
