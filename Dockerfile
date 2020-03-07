# https://www.jacoco.org/jacoco/
# https://www.eclemma.org/jacoco/trunk/doc/agent.html


ARG jacoco_version=0.8.5
ARG alpine_version=latest

FROM alpine:$alpine_version as downloader

ARG jacoco_version
ARG alpine_version

WORKDIR /jacoco

RUN apk update && apk add curl && apk add unzip && \
    checksum=$(curl -f https://www.jacoco.org/jacoco/download/jacoco-$jacoco_version.zip.md5.txt | cut -d ' ' -f 1) && \
    curl -f https://repo1.maven.org/maven2/org/jacoco/jacoco/$jacoco_version/jacoco-$jacoco_version.zip -o jacoco.zip && \
    sum=$(cat jacoco.zip | md5sum | cut -d ' ' -f 1) && \
    if [ ! $sum == $checksum ]; then exit 1; fi && \
    unzip jacoco.zip -d /jacoco && \
    rm jacoco.zip

FROM alpine:$alpine_version as prod

ARG jacoco_version
ARG alpine_version

ENV JACOCO_VERSION $jacoco_version

WORKDIR /jacoco

COPY --from=downloader /jacoco/lib/jacocoagent.jar .

CMD ["echo", "-e", "The JaCoCo agent collects execution information and dumps it on request or \nwhen the JVM exits. There are three different modes for execution data output:\n\n    1. File System: At JVM termination execution data is written to a local \n    file.\n    2. TCP Socket Server: External tools can connect to the JVM and retrieve \n    execution data over the socket connection. Optional execution data reset \n    and execution data dump on VM exit is possible.\n    3. TCP Socket Client: At startup the JaCoCo agent connects to a given TCP \n    endpoint. Execution data is written to the socket connection on request. \n    Optional execution data reset and execution data dump on VM exit is possible.\n\nThe agent jacocoagent.jar is part of the JaCoCo distribution and includes all \nrequired dependencies. A Java agent can be activated with the following JVM option:\n\n    -javaagent:/jacoco/lib/jacocoagent.jar=[option1]=[value1],[option2]=[value2]\n\nMore info please visit: https://www.eclemma.org/jacoco/trunk/doc/agent.html\n"]