FROM openjdk:18-jdk-alpine as build

LABEL org.opencontainers.image.description="Sample Java application providing server-side identity verification functionality using Falu."

WORKDIR /workspace/app

COPY gradle gradle
COPY build.gradle settings.gradle gradlew ./
COPY src src

RUN ./gradlew bootJar --stacktrace

FROM openjdk:18-jdk
VOLUME /tmp
ARG DEPENDENCY=/workspace/app/build/libs/*.jar
COPY --from=build ${DEPENDENCY} /app/identity-verification.jar
ENTRYPOINT ["java", "-jar", "/app/identity-verification.jar"]
