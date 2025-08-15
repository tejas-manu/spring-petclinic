# Stage 1: Build the application using Maven
FROM maven:3.8.8-eclipse-temurin-17 AS build

# Set the working directory
WORKDIR /app

# Copy the Maven project file
COPY pom.xml .

# Copy the source code
COPY src ./src

# Build the project and create the JAR file.
# This command skips running tests during the build.
RUN mvn clean install -DskipTests

# Stage 2: Create the final, smaller image
FROM openjdk:17-jdk-slim

# Set the working directory in the final image
WORKDIR /app

# Copy the JAR file from the 'build' stage
COPY --from=build /app/target/*.jar app.jar

# Expose the port the application will run on
EXPOSE 8090

# Set the entrypoint to run the application
# This command starts the application with the 'postgres' profile active
# on port 8090, just like your original command.
# ENTRYPOINT ["java", "-Dspring.profiles.active=postgres", "-jar", "app.jar", "--server.port=8090"]

ENTRYPOINT ["java", "-jar", "app.jar", "--server.port=8090"]
