# ---------------------------------------------------------------------------
# Stage 1 – build
# ---------------------------------------------------------------------------
FROM eclipse-temurin:17-jdk AS builder

WORKDIR /app

COPY gradlew settings.gradle build.gradle ./
COPY gradle/ gradle/
COPY .editorconfig ./

# Download dependencies first (layer cache)
RUN ./gradlew dependencies --no-daemon

COPY src/ src/

RUN ./gradlew bootJar --no-daemon -x test \
    && cp build/libs/*.jar app.jar

# ---------------------------------------------------------------------------
# Stage 2 – runtime
# ---------------------------------------------------------------------------
FROM eclipse-temurin:17-jre

RUN groupadd --system appgroup && useradd --system --gid appgroup appuser

WORKDIR /app

COPY --from=builder /app/app.jar app.jar

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
