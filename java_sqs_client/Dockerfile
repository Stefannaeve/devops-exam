FROM maven:3.9.4-eclipse-temurin-17 as builder
WORKDIR /app
COPY pom.xml pom.xml
COPY src ./src
RUN mvn package -DskipTests

FROM gcr.io/distroless/java17-debian11
WORKDIR /app
COPY --from=builder /app/target/*.jar /app/application.jar
ENTRYPOINT ["java", "-jar", "/app/application.jar"]