# set to latest Ubuntu LTS
FROM ubuntu:16.04
MAINTAINER WSO2 Docker Maintainers "dev@wso2.org"

# set user configurations
ARG USER=wso2carbon
ARG USER_ID=802
ARG USER_GROUP=wso2
ARG USER_GROUP_ID=802
ARG USER_HOME=/home/${USER}
# set dependant files directory
ARG FILES=./dockerfile
# set jdk configurations
ARG JDK=jdk1.8.0*
ARG JAVA_HOME=${USER_HOME}/java
# set wso2 product configurations
ARG WSO2_SERVER=wso2dss
ARG WSO2_SERVER_VERSION=3.5.2
ARG WSO2_SERVER_DIST=${WSO2_SERVER}-${WSO2_SERVER_VERSION}
ARG WSO2_SERVER_HOME=${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}

# install required packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl \
    netcat

# create a user group and a user
RUN groupadd --system -g ${USER_GROUP_ID} ${USER_GROUP} && \
    useradd --system --create-home --home-dir ${USER_HOME} --no-log-init -g ${USER_GROUP_ID} -u ${USER_ID} ${USER}

# copy the jdk and wso2 product distributions to user's home directory and copy the mysql connector jar to server distribution
COPY --chown=wso2carbon:wso2 ${FILES}/${JDK} ${USER_HOME}/java/
COPY --chown=wso2carbon:wso2 ${FILES}/${WSO2_SERVER_DIST} ${USER_HOME}/${WSO2_SERVER_DIST}
COPY --chown=wso2carbon:wso2 ${FILES}/init.sh ${USER_HOME}/
COPY --chown=wso2carbon:wso2 ${FILES}/mysql-connector-java-*.jar ${USER_HOME}/${WSO2_SERVER_DIST}/repository/components/lib/
COPY --chown=wso2carbon:wso2 ${FILES}/wso2aac.client-1.0.jar ${USER_HOME}/${WSO2_SERVER_DIST}/repository/components/lib/
#COPY --chown=wso2carbon:wso2 ${FILES}/kubernetes-membership-scheme-*.jar ${USER_HOME}/${WSO2_SERVER_DIST}/repository/components/dropins/
# set temporary location for shared artifacts
COPY --chown=wso2carbon:wso2 ${FILES}/${WSO2_SERVER_DIST}/repository/deployment/server ${USER_HOME}/wso2-tmp/server

# set the user and work directory
USER ${USER_ID}
WORKDIR ${USER_HOME}

# set environment variables
ENV JAVA_HOME=${JAVA_HOME} \
    PATH=$JAVA_HOME/bin:$PATH \
    WSO2_SERVER_HOME=${WSO2_SERVER_HOME} \
    WORKING_DIRECTORY=${USER_HOME}

# expose ports
EXPOSE 9763 9443

ENTRYPOINT ${WORKING_DIRECTORY}/init.sh
