FROM openjdk:8u212-stretch
RUN wget https://downloads.bouncycastle.org/fips-java/bc-fips-1.0.1.jar -P /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ext
RUN cp -a /etc/java-8-openjdk/security/java.security /etc/java-8-openjdk/security/java.security.orig
COPY java.security.fips /etc/java-8-openjdk/security/java.security

RUN cp -a /etc/ssl/certs/java/cacerts /etc/ssl/certs/java/cacerts.orig
RUN rm /etc/ssl/certs/java/cacerts
RUN keytool -importkeystore -srckeystore /etc/ssl/certs/java/cacerts.orig -srcstoretype JKS -destkeystore /etc/ssl/certs/java/cacerts -deststoretype BCFKS -deststorepass changeit -srcstorepass changeit

COPY Test.java /
RUN javac /Test.java
RUN java Test