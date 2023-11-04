# Custom JRE

FROM maven:3.9.5-eclipse-temurin-21-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the project's pom.xml and initial source code to the container
COPY pom.xml .
COPY src ./src

# Run Maven package phase, which builds the application and dependencies
RUN mvn clean package


FROM eclipse-temurin:21-jdk-alpine as deps

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


COPY --from=build /app/target/*.jar /app/app.jar

# Identify dependencies
# COPY ./target/hello-world-0.0.1-SNAPSHOT.jar /app/app.jar
RUN mkdir /app/unpacked && \
    cd /app/unpacked && \
    unzip ../app.jar && \
    cd .. && \
    $JAVA_HOME/bin/jdeps \
    --ignore-missing-deps \
    --print-module-deps \
    -q \
    --recursive \
    --multi-release 19 \
    --class-path="./unpacked/BOOT-INF/lib/*" \
    --module-path="./unpacked/BOOT-INF/lib/*" \
    ./app.jar > /deps.info

# -------------------------------------------------------------

# FROM azul/zulu-openjdk-alpine:21-latest as openjdk
FROM eclipse-temurin:21-jdk-alpine as customjdk

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8



# required for strip-debug to work
RUN apk add --no-cache binutils

# copy module dependencies info
COPY --from=deps /deps.info /deps.info

# Build small JRE image
RUN $JAVA_HOME/bin/jlink \
    --verbose \
    --add-modules $(cat /deps.info) \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /customjre

# main app image

FROM alpine:latest
ENV JAVA_HOME=/jre
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# copy JRE from the base image
COPY --from=customjdk /customjre $JAVA_HOME

# Add app user
ARG APPLICATION_USER=appuser
RUN adduser --no-create-home -u 1000 -D $APPLICATION_USER

# Configure working directory
RUN mkdir /app && \
    chown -R $APPLICATION_USER /app

USER 1000

COPY --chown=1000:1000 --from=build /app/target/*.jar /app/app.jar
WORKDIR /app


# EXPOSE 8080
# ENTRYPOINT [ "/jre/bin/java", "-Xmx1G","-jar", "/app/app.jar" ]
ENTRYPOINT [ "/jre/bin/java","-jar", "/app/app.jar" ]