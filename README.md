# WebSphere Application Server in IBM Cloud

IBM [WebSphere Application Server in IBM Cloud][wasaas_docs_url] is a service in IBM Cloud that facilitates quick setup on a pre-configured WebSphere Application Server Liberty, Traditional Network Deployment, or Traditional WebSphere instance in a hosted cloud environment.

WebSphere Application Server in IBM Cloud provides consumers with pre-configured Traditional WebSphere and Liberty Profile servers. It is hosted on virtual machine guests with root access to the guest operating system. When you are creating your service, choose between Liberty, Traditional ND, or Traditional WebSphere.

You can create and manage this service in 2 ways

  1. In your browser by creating an instance via the [IBM Cloud Catalog][catalog_url]
  1. Programmatically using the WebSphere Application Server in IBM Cloud *API*

The example code in the WebSphere-In-IBM-Cloud-API-Examples folder contains Java code that utilizes the API to perform tasks such as:

  * Create a service instance.
  * Read credentials for your machine.
  * Start / Stop your machine.
  * Delete a service instance
  * And more...

The example code in the Scaling-Service-Example folder contains a script that utilizes the API to perform tasks such as:

  * Review resources running within a service instance
  * Start desired number of nodes within a service instance
  * Stop desired number of nodes within a service instance

[wasaas_docs_url]: https://cloud.ibm.com/docs/services/ApplicationServeronCloud/index.html#about
[catalog_url]: https://cloud.ibm.com/catalog/services/websphere-application-server