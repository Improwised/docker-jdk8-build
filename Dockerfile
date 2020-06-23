FROM openjdk:8-jdk-alpine

# Define a constant with the version of maven you want to install
ARG MAVEN_VERSION=3.6.3

# Installing necessary packages
RUN apk add --no-cache curl tar bash procps zip tar wget git docker openrc python3 protobuf

# Installing glibc for protobuf
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.31-r0/glibc-2.31-r0.apk \
    && apk add glibc-2.31-r0.apk

# Downloading gcloud package
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

# Installing the package
RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh --quiet

# Adding the package path to local
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin
# ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
# ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/bin
# Create the directories, download maven, validate the download, install it, remove downloaded file and set links
RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && echo "Downloading maven" \
  && curl -fsSL -o /tmp/apache-maven.tar.gz http://apachemirror.wuchna.com/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  \
  && echo "Unzipping maven" \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  \
  && echo "Cleaning and setting links" \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

# Define environmental variables required by Maven, like Maven_Home directory and where the maven repo is located
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "/root/.m2"
