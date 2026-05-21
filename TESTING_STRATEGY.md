# Testing Strategy — Spring PetClinic

## Overview

This document describes the testing strategy for the Spring PetClinic application. The goal is to maintain **≥ 80% instruction coverage** and **≥ 70% branch coverage** across the entire codebase, enforced automatically via JaCoCo during every build.

## Test Layers

### 1. Unit Tests

Lightweight tests that exercise individual classes in isolation, without starting the Spring context.

- **Domain model tests** (`OwnerTests`, `VetTests`, `ValidatorTests`): verify entity logic, getters/setters, and business rules.
- **Validator tests** (`PetValidatorTests`): verify bean validation constraints.
- **Runtime hints tests** (`PetClinicRuntimeHintsTests`): verify AOT/GraalVM resource and serialization hints.

**Conventions:**
- Use JUnit 5 (`@Test`, `@Nested`).
- Assertions via AssertJ (`assertThat`).
- No Spring context required — keeps execution fast (< 1 s per test class).

### 2. WebMvc Slice Tests

Tests that start a minimal Spring context with only the web layer (`@WebMvcTest`), using MockMvc for HTTP simulation and Mockito for repository mocks.

- `OwnerControllerTests`, `PetControllerTests`, `VisitControllerTests`, `VetControllerTests`
- `CrashControllerTests`, `WelcomeControllerTests`

**Conventions:**
- Annotate with `@WebMvcTest(ControllerUnderTest.class)`.
- Use `@MockitoBean` for repository dependencies.
- Use `@DisabledInNativeImage` and `@DisabledInAotMode` (mocking is unsupported in native/AOT).
- Cover success paths, validation error paths, and edge cases (not found, id mismatch).

### 3. Integration Tests

Full-context tests that boot the entire Spring Boot application, verifying end-to-end wiring, JPA repository queries, and database interactions.

- `PetClinicIntegrationTests`: H2 in-memory database.
- `MySqlIntegrationTests`: Testcontainers-based MySQL.
- `PostgresIntegrationTests`: Testcontainers-based PostgreSQL.
- `ClinicServiceTests`: service-layer integration with the default profile.
- `CacheConfigurationTests`: verifies JCache/Caffeine cache wiring.
- `CrashControllerIntegrationTests`: verifies error handling with full stack.

**Conventions:**
- Annotate with `@SpringBootTest`.
- Database-specific tests use `@Testcontainers` and `@ServiceConnection` for automatic datasource wiring.
- Use `@DisabledInNativeImage` and `@DisabledInAotMode` where applicable.

## Coverage Enforcement

### JaCoCo Configuration

JaCoCo is configured in `pom.xml` with three execution phases:

| Execution | Phase | Purpose |
|-----------|-------|---------|
| `prepare-agent` | `initialize` | Instruments bytecode for coverage collection |
| `report` | `prepare-package` | Generates HTML/CSV/XML reports in `target/site/jacoco/` |
| `check` | `verify` | Fails the build if coverage drops below thresholds |

### Minimum Thresholds

| Counter | Minimum | Scope |
|---------|---------|-------|
| Instruction | 80% | Bundle (whole project) |
| Branch | 70% | Bundle (whole project) |

These thresholds are enforced during `mvn verify`. Any PR that drops coverage below these limits will fail CI.

### Current Coverage

| Metric | Value |
|--------|-------|
| Instruction | ~94% |
| Branch | ~89% |

## CI Integration

### GitHub Actions (`maven-build.yml`)

The Maven CI workflow runs on every push to `main` and on every pull request targeting `main`:

1. **Build & Test**: `./mvnw -B verify` — compiles, runs all tests, generates the JaCoCo report, and enforces coverage thresholds.
2. **Upload Report**: The JaCoCo HTML report is uploaded as a build artifact (`jacoco-report-jdk17`).
3. **Coverage Summary**: A per-class coverage table is rendered in the GitHub Actions step summary.

### Viewing Coverage

- **Locally**: Run `./mvnw verify` and open `target/site/jacoco/index.html`.
- **CI**: Download the `jacoco-report-jdk17` artifact from the GitHub Actions run, or view the step summary.

## Adding New Tests

When adding a new feature or fixing a bug:

1. **Unit test first**: If the change is in a domain model or utility class, write a plain JUnit 5 unit test.
2. **WebMvc test for controllers**: If you add or modify a controller endpoint, add a `@WebMvcTest` for it.
3. **Integration test for wiring**: If the change involves repository queries, caching, or cross-cutting concerns, add or extend a `@SpringBootTest`.
4. **Verify locally**: Run `./mvnw verify` to confirm coverage still meets thresholds.

## Exclusions

The following classes are excluded from strict per-class coverage expectations (though they still count toward the bundle total):

- `PetClinicApplication`: Only contains `main()`, which is tested indirectly by `@SpringBootTest`.
- `CacheConfiguration`: Cache manager wiring depends on JCache provider availability.
- `package-info.java` files: No executable code.
