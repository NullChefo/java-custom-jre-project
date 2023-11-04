# java-custom-jre-project
Dockerfile creating custom jre


# To build image
docker build -t hello-world-java-image .

# To run the image

docker run --name hello-world-java-container -p 8080:8080 hello-world-java-image:latest




# Dockerfile not recommended use

docker build -t hello-world-java-not-recommended-image --file Dockerfile-not-recommended .

docker run --name hello-world-java-not-recommended-container -p 8080:8080 hello-world-java-not-recommended-image:latest


# Dockerfile native image

## FOR THIS YOU SHOULD USE JAVA 17

docker build -t hello-world-java-native-image --file Dockerfile-native-image .

docker run --name hello-world-java-native-image-container -p 8080:8080 hello-world-java-native-image:latest
