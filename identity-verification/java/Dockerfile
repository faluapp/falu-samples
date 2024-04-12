FROM openjdk:8-jdk-alpine as build

LABEL org.opencontainers.image.description="Sample Java application providing server-side identity verification functionality using Falu."

WORKDIR /workspace/app

COPY gradle gradle
COPY build.gradle settings.gradle gradlew ./
COPY src src

RUN ./gradlew build -x test
RUN mkdir -p build/libs/dependency && (cd build/libs/dependency; jar -xf ../*.jar)

FROM openjdk:8-jdk-alpine
VOLUME /tmp
ARG DEPENDENCY=/workspace/app/build/libs/dependency
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app
ENTRYPOINT ["java", "-cp", "app:app/lib/*", "io.falu.samples.identity"]

