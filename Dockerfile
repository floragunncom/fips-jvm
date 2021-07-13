#FROM openjdk:8u212-stretch
FROM openjdk:8u292-jdk-buster

ARG JAVA_HOME=/usr/local/openjdk-8
ARG JRE_HOME=$JAVA_HOME/jre

##### Install the BC-FIPS jar
#Get BC-FIPS and put it in jre/lib/ext directory
#RUN wget https://downloads.bouncycastle.org/fips-java/bc-fips-1.0.2.1.jar -P $JRE_HOME/lib/ext
COPY bc-fips-1.0.2.1.jar $JRE_HOME/lib/ext

##### Change the providers in java.security
#Backup the original java.security file
RUN cp -a $JRE_HOME/lib/security/java.security $JRE_HOME/lib/security/java.security.orig
#Replace it by our FIPS one (FIPS first)
COPY java.security.fips $JRE_HOME/lib/security/java.security

##### Change cacerts format
#Backup cacerts
#RUN cp -a $JRE_HOME/lib/security/cacerts $JRE_HOME/lib/security/cacerts.orig
#Create a cacert with the format BCFKS with all the certificates in the original cacerts
#RUN rm $JRE_HOME/lib/security/cacerts
#RUN keytool -importkeystore -srckeystore $JRE_HOME/lib/security/cacerts.orig -srcstoretype JKS -destkeystore $JRE_HOME/lib/security/cacerts -deststoretype BCFKS -deststorepass changeit -srcstorepass changeit

#Run some tests
COPY Test.java /
RUN javac /Test.java
RUN java Test

#Run an agent
RUN mkdir /agent && mkdir /agent/tmp
COPY agent.jar /agent
COPY secret.txt /agent
COPY fips-security-manager-1.0-SNAPSHOT.jar /agent
WORKDIR /agent


#Debugging port
EXPOSE 5006 
ENV JAVA_TOOL_OPTIONS "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5006"
#ENTRYPOINT ["java", "-cp", "fips-security-manager-1.0-SNAPSHOT.jar", "-Dorg.bouncycastle.fips.approved_only=true", "-Djava.security.manager=com.cloudbees.cbci.fips_security_manager.FIPSSecurityManager", "-Djavax.net.ssl.trustStoreType=JKS", "-jar", "agent.jar", "-jnlpUrl", "http://host.docker.internal:8080/computer/my-jnlp-node/jenkins-agent.jnlp", "-secret", "@secret.txt", "-workDir", "/agent/tmp"]
ENTRYPOINT ["java", "-cp", "fips-security-manager-1.0-SNAPSHOT.jar", "-Dorg.bouncycastle.fips.approved_only=true", "-Djavax.net.ssl.trustStoreType=JKS", "-jar", "agent.jar", "-jnlpUrl", "http://host.docker.internal:8080/computer/my-jnlp-node/jenkins-agent.jnlp", "-secret", "@secret.txt", "-workDir", "/agent/tmp"]

#Build the image
#docker build . -t fips-java

#Run the container
#docker run -d --name agent-fips -P fips-java; docker logs -f agent-fip