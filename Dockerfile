# syntax=docker/dockerfile:1.6

# =========================
# Stage 1: builder
# =========================
FROM eclipse-temurin:17-jdk AS builder

WORKDIR /workspace

# Copy Maven wrapper and POM first to leverage Docker layer caching.
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN chmod +x mvnw && ./mvnw -B -q dependency:go-offline

# Copy the rest of the source and build the application.
COPY src ./src
RUN ./mvnw -B -DskipTests package \
    && cp target/*.jar /workspace/app.jar

# =========================
# Stage 2: runtime
# =========================
FROM eclipse-temurin:17-jre AS runtime

# Create a non-root user to run the application.
RUN groupadd --system --gid 1001 appuser \
    && useradd  --system --uid 1001 --gid 1001 --home /app --shell /sbin/nologin appuser

WORKDIR /app

# Copy the built JAR from the builder stage and assign ownership to the non-root user.
COPY --from=builder --chown=appuser:appuser /workspace/app.jar /app/app.jar

USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
