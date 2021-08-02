FROM openjdk:16-jdk-alpine as builder
WORKDIR build
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} application.jar
RUN java -Djarmode=layertools -jar application.jar extract

FROM adoptopenjdk/openjdk16:alpine-jre
WORKDIR application
COPY --from=builder build/dependencies/ ./
COPY --from=builder build/spring-boot-loader ./
COPY --from=builder build/snapshot-dependencies/ ./
COPY --from=builder build/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]

