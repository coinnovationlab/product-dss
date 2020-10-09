#!/bin/bash -e

[ -f "./common.sh" ] && . "./common.sh"
#[ -f "./env.properties" ] && . env.properties
# WSO2_SERVER_HOME="./test"
# DSS_USER="admin"
# DSS_PASS="pass123"
# DSS_SERVER_URL="https://dss.platform.local"
# DSS_REVERSEPROXY="dss.platform.local"
# #DSS_GATEWAYENDPOINT="gwapim.platform.domain.com"
# # ANALYTICS_HOSTNAME="wso2apim-with-analytics-apim-analytics-service"
# # AAC_HOSTNAME="aac"
# AAC_CONSUMERKEY="API_MGT_CLIENT_ID"
# AAC_CONSUMERSECRET="API_MGT_CLIENT_SECRET"
# AAC_REVERSEPROXY="https://aac.platform.local"
# MYSQL_HOSTNAME="mysql"
# MYSQL_USER="user"
# MYSQL_PASS="pass"
# DSS_DRIVER_CLASS_NAME="com.mysql.jdbc.Driver"
# DSS_KEYSTORE_FILENAME="dss.jks"
# DSS_KEYSTORE_PASS="kubetest"
# DSS_KEYSTORE_KEYALIAS="dss"
# DSS_TRUSTSTORE_FILENAME="client.jks"
# DSS_TRUSTSTORE_PASS="kubetest"
# DSS_PORT="443"

# Directory ${WSO2_SERVER_HOME}/repository/conf
conf_path="${WSO2_SERVER_HOME}/repository/conf"
# Edit properties in user-mgt.xml file
conf_file='user-mgt.xml'
echo ${conf_file}
xml_replace 'UserName' ${DSS_USER} '/UserManager/Realm/Configuration/AdminUser' "${conf_path}/${conf_file}"
xml_replace 'Password' ${DSS_PASS} '/UserManager/Realm/Configuration/AdminUser' "${conf_path}/${conf_file}"
xml_replace 'Property[@name="UserRolesCacheEnabled"]' "false" '//UserManager/Realm/UserStoreManager[@class="org.wso2.carbon.user.core.jdbc.JDBCUserStoreManager"]' "${conf_path}/${conf_file}"

# Edit properties in carbon.xml file
## xml with default namaspace declaration using underscore _ to match namespace
conf_file='carbon.xml'
echo ${conf_file}
xml_uncomment 'HostName' "${conf_path}/${conf_file}"
xml_uncomment 'MgtHostName' "${conf_path}/${conf_file}"
xml_replace '_:HostName' "${DSS_REVERSEPROXY}" '_:Server' "${conf_path}/${conf_file}"
xml_replace '_:MgtHostName' "${DSS_REVERSEPROXY}" '_:Server' "${conf_path}/${conf_file}"
xml_replace '_:ServerURL' "${DSS_SERVER_URL}/services/" '_:Server' "${conf_path}/${conf_file}"
if [ ! -z ${DSS_KEYSTORE_FILENAME} ]; then
  xml_replace '_:Location' "\${carbon.home}/repository/resources/security/${DSS_KEYSTORE_FILENAME}" '_:Server/_:Security/_:KeyStore' "${conf_path}/${conf_file}"
  xml_replace '_:Password' "${DSS_KEYSTORE_PASS}" '_:Server/_:Security/_:KeyStore' "${conf_path}/${conf_file}"
  xml_replace '_:KeyAlias' "${DSS_KEYSTORE_KEYALIAS}" '_:Server/_:Security/_:KeyStore' "${conf_path}/${conf_file}"
  xml_replace '_:KeyPassword' "${DSS_KEYSTORE_PASS}" '_:Server/_:Security/_:KeyStore' "${conf_path}/${conf_file}"
  xml_replace '_:Location' "\${carbon.home}/repository/resources/security/${DSS_TRUSTSTORE_FILENAME}" '_:Server/_:Security/_:TrustStore' "${conf_path}/${conf_file}"
  xml_replace '_:Password' "${DSS_TRUSTSTORE_PASS}" '_:Server/_:Security/_:TrustStore' "${conf_path}/${conf_file}"
fi

# Edit properties in sec.policy file
conf_file='sec.policy'
echo ${conf_file}
sed -i -e "s|wso2carbon.jks|${DSS_KEYSTORE_FILENAME}|" "${conf_path}/${conf_file}"

# Directory ${WSO2_SERVER_HOME}/repository/conf/datasources
conf_path="${WSO2_SERVER_HOME}/repository/conf/datasources"
conf_file='master-datasources.xml'
echo ${conf_file}
## Edit properties in master-datasources.xml file
### DSS
xml_replace 'url' "jdbc:mysql://${MYSQL_HOSTNAME}:3306/dss?autoReconnect=true&useSSL=false" '//datasources-configuration/datasources/datasource[name="WSO2_CARBON_DB"]/definition/configuration' "${conf_path}/${conf_file}"
xml_replace 'username' "${MYSQL_USER}" '//datasources-configuration/datasources/datasource[name="WSO2_CARBON_DB"]/definition/configuration' "${conf_path}/${conf_file}"
xml_replace 'password' "${MYSQL_PASS}" '//datasources-configuration/datasources/datasource[name="WSO2_CARBON_DB"]/definition/configuration' "${conf_path}/${conf_file}"
xml_replace 'driverClassName' "${DSS_DRIVER_CLASS_NAME}" '//datasources-configuration/datasources/datasource[name="WSO2_CARBON_DB"]/definition/configuration' "${conf_path}/${conf_file}"


# Directory ${WSO2_SERVER_HOME}/repository/conf/security
conf_path="${WSO2_SERVER_HOME}/repository/conf/security"
conf_file='authenticators.xml'
echo ${conf_file}
## Edit properties in authenticators.xml file
### DSS
xml_append 'Authenticator' ' ' '/_:Authenticators/_:Authenticator[@name="TokenUIAuthenticator"]' "${conf_path}/${conf_file}" 'name=OAUTH2SSOAuthenticator' 'disabled=false'
xml_add 'Priority' '3' '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]' "${conf_path}/${conf_file}"
xml_add 'Config' ' ' '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]' "${conf_path}/${conf_file}"
xml_add 'Parameter' 'AAC' '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config' "${conf_path}/${conf_file}"
xml_append_attr '_:Parameter' 'name=OauthProviderName' '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config' "${conf_path}/${conf_file}"
xml_append 'Parameter' '/carbon/admin/login.jsp' '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="OauthProviderName"]' "${conf_path}/${conf_file}" 'name=LoginPage'
xml_append 'Parameter' 'carbonServer' '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="LoginPage"]' "${conf_path}/${conf_file}" 'name=ServiceProviderID'
xml_append 'Parameter' "${AAC_REVERSEPROXY}" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="ServiceProviderID"]' "${conf_path}/${conf_file}" 'name=IdentityProviderSSOServiceURL'
xml_append 'Parameter' "${DSS_SERVER_URL}/carbon/oauth2-sso-acs/custom_login.jsp" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="IdentityProviderSSOServiceURL"]' "${conf_path}/${conf_file}" 'name=LandingPage'
xml_append 'Parameter' "${DSS_SERVER_URL}/oauth2_acs" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="LandingPage"]' "${conf_path}/${conf_file}" 'name=RedirectURL'
xml_append 'Parameter' "true" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="RedirectURL"]' "${conf_path}/${conf_file}" 'name=UserProvisioningEnabled'
xml_append 'Parameter' "true" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="UserProvisioningEnabled"]' "${conf_path}/${conf_file}" 'name=TenantProvisioningEnabled'
xml_append 'Parameter' "${DSS_REVERSEPROXY}" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="TenantProvisioningEnabled"]' "${conf_path}/${conf_file}" 'name=TenantDefault'
xml_append 'Parameter' "${AAC_CONSUMERKEY}" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="TenantDefault"]' "${conf_path}/${conf_file}" 'name=ClientID'
xml_append 'Parameter' "${AAC_CONSUMERSECRET}" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="ClientID"]' "${conf_path}/${conf_file}" 'name=ClientSecret'
xml_append 'Parameter' "${AAC_REVERSEPROXY}/oauth/authorize" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="ClientSecret"]' "${conf_path}/${conf_file}" 'name=AuthorizationURL'
xml_append 'Parameter' "${AAC_HOSTNAME}/oauth/token" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="AuthorizationURL"]' "${conf_path}/${conf_file}" 'name=TokenURL'
xml_append 'Parameter' "${AAC_HOSTNAME}/oauth/introspect" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="TokenURL"]' "${conf_path}/${conf_file}" 'name=CheckTokenEndpointUrl'
xml_append 'Parameter' "${AAC_HOSTNAME}/basicprofile/me" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="CheckTokenEndpointUrl"]' "${conf_path}/${conf_file}" 'name=APIUserInfoURL'
xml_append 'Parameter' "${AAC_HOSTNAME}/userroles/me" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="APIUserInfoURL"]' "${conf_path}/${conf_file}" 'name=APIRoleInfoURL'
xml_append 'Parameter' "${AAC_HOSTNAME}/userroles/token" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="APIRoleInfoURL"]' "${conf_path}/${conf_file}" 'name=GetRolesOfTokenURL'
xml_append 'Parameter' "${AAC_HOSTNAME}/apikeycheck" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="GetRolesOfTokenURL"]' "${conf_path}/${conf_file}" 'name=ApiKeyCheckURL'
xml_append 'Parameter' "86400" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="ApiKeyCheckURL"]' "${conf_path}/${conf_file}" 'name=MaxExpireSecToken'
xml_append 'Parameter' "profile.basicprofile.me profile.accountprofile.me user.roles.me user.roles.read" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="MaxExpireSecToken"]' "${conf_path}/${conf_file}" 'name=ScopesListUserInfo'
xml_append 'Parameter' "username" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="ScopesListUserInfo"]' "${conf_path}/${conf_file}" 'name=UserNameField'
xml_append 'Parameter' "${DSS_ROLE_CONTEXT}" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="UserNameField"]' "${conf_path}/${conf_file}" 'name=RoleContext'
xml_append 'Parameter' "${DSS_SERVER_URL}/carbon/oauth2-sso-acs/select_tenant.jsp" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="RoleContext"]' "${conf_path}/${conf_file}" 'name=SelectTenantURL'
xml_append 'Parameter' "${DSS_SERVER_URL}/forwardtenant" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="SelectTenantURL"]' "${conf_path}/${conf_file}" 'name=TenantSelectedURL'
xml_append 'Parameter' "org.wso2.carbon.dataservices.core.security.filter.ServicesSecurityFilter" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="TenantSelectedURL"]' "${conf_path}/${conf_file}" 'name=SecurityFilterClass'
xml_append 'Parameter' "ROLE_MANAGER" '//_:Authenticators/_:Authenticator[@name="OAUTH2SSOAuthenticator"]/_:Config/_:Parameter[@name="SecurityFilterClass"]' "${conf_path}/${conf_file}" 'name=RoleProvider'
xml_replace '_:Parameter[@name="IdentityProviderSSOServiceURL"]' "${DSS_SERVER_URL}/samlsso" '//_:Authenticators/_:Authenticator[@name="SAML2SSOAuthenticator"]/_:Config' "${conf_path}/${conf_file}"
xml_replace '_:Parameter[@name="AssertionConsumerServiceURL"]' "${DSS_SERVER_URL}/acs" '//_:Authenticators/_:Authenticator[@name="SAML2SSOAuthenticator"]/_:Config' "${conf_path}/${conf_file}"

# Directory ${WSO2_SERVER_HOME}/repository/conf/security
conf_path="${WSO2_SERVER_HOME}/repository/conf/security"
conf_file='Owasp.CsrfGuard.Carbon.properties'
echo ${conf_file}
## Edit properties in Owasp.CsrfGuard.Carbon.properties file
prop_replace 'org.owasp.csrfguard.UnprotectedMethods' 'GET,POST' "${conf_path}/${conf_file}"

# Directory ${WSO2_SERVER_HOME}/repository/conf/tomcat
conf_path="${WSO2_SERVER_HOME}/repository/conf/tomcat"
conf_file='catalina-server.xml'
echo ${conf_file}
## Edit properties in catalina-server.xml file
xml_append_attr 'Connector[@port="9443"]' "proxyName=${DSS_REVERSEPROXY}" '/Server/Service' "${conf_path}/${conf_file}"
xml_append_attr 'Connector[@port="9443"]' "proxyPort=${DSS_PORT}" '/Server/Service' "${conf_path}/${conf_file}"
xml_replace '@maxHttpHeaderSize' "65536" '/Server/Service/Connector[@port="9443"]' "${conf_path}/${conf_file}"
if [ ! -z ${DSS_KEYSTORE_FILENAME} ]; then
  xml_replace '@keystoreFile' "\${carbon.home}/repository/resources/security/${DSS_KEYSTORE_FILENAME}" '/Server/Service/Connector[@port="9443"]' "${conf_path}/${conf_file}"
  xml_replace '@keystorePass' "${DSS_KEYSTORE_PASS}" '/Server/Service/Connector[@port="9443"]' "${conf_path}/${conf_file}"
fi

# Directory ${WSO2_SERVER_HOME}/repository/conf/tomcat
conf_path="${WSO2_SERVER_HOME}/repository/conf/tomcat"
conf_file='web.xml'
echo ${conf_file}
## Edit properties in web.xml file
sed -i ':a;N;$!ba;s/xmlns.*=".*"\n//g' "${conf_path}/${conf_file}"
xml_add 'cookie-config' ' ' '//web-app/session-config' "${conf_path}/${conf_file}"
xml_add 'name' 'JSESSIONID_DSS' '//web-app/session-config/cookie-config' "${conf_path}/${conf_file}"

### Directory ${WSO2_SERVER_HOME}/repository/conf/identity
conf_path="${WSO2_SERVER_HOME}/repository/conf/identity"
## Edit properties in identity.xmln
conf_file='identity.xml'
echo ${conf_file}
if [ ! -z ${DSS_KEYSTORE_FILENAME} ]; then
  xml_replace '_:Location' "\${carbon.home}/repository/resources/security/${DSS_KEYSTORE_FILENAME}" '//_:Server/_:EntitlementSettings/_:ThirftBasedEntitlementConfig/_:KeyStore' "${conf_path}/${conf_file}"
  xml_replace '_:Password' "${DSS_KEYSTORE_PASS}" '//_:Server/_:EntitlementSettings/_:ThirftBasedEntitlementConfig/_:KeyStore' "${conf_path}/${conf_file}"
fi
