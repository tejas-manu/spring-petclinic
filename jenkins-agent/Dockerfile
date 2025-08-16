# Use a base image that already has some Jenkins tools
FROM jenkins/inbound-agent:latest-jdk17

# Use arguments to define the UID and GID (replace with your values from Step 1)
ARG JENKINS_UID=111
ARG JENKINS_GID=113

# Install necessary tools
USER root
RUN apt-get update && apt-get install -y \
    docker.io \
    curl \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add a user with the same UID and GID as the Jenkins user on the host
RUN groupadd -g $JENKINS_GID zap_group && \
    useradd -m -s /bin/bash -u $JENKINS_UID -g $JENKINS_GID zap_user

# Add zap_user to the docker group so they can use the docker daemon
RUN usermod -aG docker zap_user

# Pull the ZAP image during the build to avoid pulling it in the pipeline
RUN docker pull zaproxy/zap-stable

# Switch to the new user
USER zap_user