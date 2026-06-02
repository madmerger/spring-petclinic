# =============================================================================
# Multi-stage Dockerfile for Spring PetClinic
# =============================================================================
# Usage:
#   docker build -t petclinic .
#   docker run -p 8080:8080 petclinic
#
# Spring Boot Buildpacks are still available via:
#   ./mvnw spring-boot:build-image
# =============================================================================

# ---------------------------------------------------------------------------
# Stage 1: Build
# ---------------------------------------------------------------------------
FROM eclipse-temurin:17-jdk-alpine AS builder

WORKDIR /app

# Copy Maven wrapper and pom first for layer caching
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN chmod +x mvnw && ./mvnw dependency:go-offline -B

# Copy source and build
COPY src/ src/
RUN ./mvnw package -DskipTests -B && \
    mv target/spring-petclinic-*.jar target/app.jar

# ---------------------------------------------------------------------------
# Stage 2: Runtime
# ---------------------------------------------------------------------------
FROM eclipse-temurin:17-jre-alpine

RUN addgroup -S petclinic && adduser -S petclinic -G petclinic

WORKDIR /app

COPY --from=builder /app/target/app.jar app.jar

RUN chown -R petclinic:petclinic /app

USER petclinic

EXPOSE 8080

ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-jar", "app.jar"]
