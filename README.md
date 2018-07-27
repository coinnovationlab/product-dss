# product-dss


This is a fork of WSO2 product-dss repository.<br>
WSO2 Data Services Server is based on Java OSGi technology, which allows components to be dynamically installed, started, stopped, updated, and uninstalled while eliminating component version conflicts. <br>
<br>

# Co-Innovation Lab enhancments 

As part of the DigitalHub Data Services Server's role is to expose the information managed by the platform as Open Data available for further use by external applications and stakeholders.<br>
A fundamental role in exposing the data belongs to the domain-specific models, which allows for linking and aligning the datasets coming from different independent sources.<br>

This repository combines the set of customized components and features for integrating DSS inside the platform.
Below there are listed the improvements done in order to make this product more customizable and secure taking in consideration the performance:

### 1. OData Olingo implementation performance improvements 
  - Max limit of records parameter in order to limit the amount of records to be retrieved
  - Implementation of ExpressionVisitor in order to elaborate Sql queries( RDBMS datasources - tested on MySQL, PostgreSQL, SQLServer, H2)
  - Cassandra performance improvements  

### 2. OData parameters configuration :  
  - DB Schema parameter configuration 
  - Possibility to configure and read views not only tables
  - Columns configuration in order to limit the list of columns to be exposed over OData Service.
  - Columns Type configuration in order to have the possibility to transform the type of data that are defined in specific format but contain another data type.

### 3. OData/REST security filter 
  - Possibility to set Public / Private services <br>
        - Set Public Services by default<br>
        - Flexible security implementation by defining the specific class inside Custom Authenticator configurations.
  - Api Key Request parameter check
  - Header Authorization token check 
  - Control both b. and c. scenarios toward AAC for defining the level of access and as a consequence permit or not the request to display data. 

### 4. OAUTH2 Custom Authenticator   
  - OSGi component creation for backend/frontend/stub bundles integration(Repo: https://github.com/coinnovationlab/wso2-dss.authenticator-oauth2)
  - Support OAUTH2 Providers parametrization (tested on Google, AAC)
  - Tenant selection on login if the same user is part of multi spaces.
  - Provision of tenants and users on the fly by defining access level depending on AAC Roles.




