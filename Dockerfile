FROM eclipse-temurin:21.0.1_12-jdk-jammy as builder
WORKDIR build
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} application.jar
RUN java -Djarmode=tools -jar application.jar extract --layers --launcher

FROM eclipse-temurin:21-jre-alpine
WORKDIR application
COPY --from=builder build/application/dependencies/ ./
COPY --from=builder build/application/spring-boot-loader ./
COPY --from=builder build/application/snapshot-dependencies/ ./
COPY --from=builder build/application/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]
