FROM eclipse-temurin:21.0.1_12-jdk-jammy as builder
WORKDIR build
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} application.jar
RUN java -Djarmode=layertools -jar application.jar extract

FROM eclipse-temurin:21-jre-alpine
WORKDIR application
COPY --from=builder build/dependencies/ ./
COPY --from=builder build/spring-boot-loader ./
COPY --from=builder build/snapshot-dependencies/ ./
COPY --from=builder build/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]

