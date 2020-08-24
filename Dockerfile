FROM openjdk:11-jdk-slim as builder
WORKDIR build
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} application.jar
RUN java -Djarmode=layertools -jar application.jar extract
RUN ls -alh

FROM openjdk:11-jdk-slim
WORKDIR application
COPY --from=builder build/dependencies/ ./
COPY --from=builder build/spring-boot-loader ./
COPY --from=builder build/snapshot-dependencies/ ./
RUN true
COPY --from=builder build/application/ ./
RUN true
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]

