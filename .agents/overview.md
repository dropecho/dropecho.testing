# Project Overview

**dropecho.testing** is a Haxe library (v1.2.0) that provides zero-configuration automated test discovery and execution. It wraps the Buddy and UTest testing frameworks, automatically finding and running test files without manual registration.

## What It Does

- Scans the classpath at **compile time** for files matching `*Tests.hx`
- Detects which test framework is available (Buddy or UTest)
- Generates a synthetic `TestSuites` class that instantiates and runs all discovered test suites
- Optionally integrates with the `instrument` library for code coverage and profiling
- Provides a `haxelib run dropecho.testing` CLI for multi-target test execution

## Package Metadata

| Field | Value |
|-------|-------|
| Haxelib name | `dropecho.testing` |
| Version | 1.2.0 |
| License | MIT |
| Author | Benjamin Van Treese |
| Classpath | `src/` |
| Haxelib main | `tools.Run` |
| No runtime dependencies | (framework detection happens at compile time) |

## Supported Test Frameworks

- **Buddy** — detected via `buddy.Buddy` class availability
- **UTest** — detected via `utest.Runner` class availability

## Optional Instrumentation

Conditional compilation (`#if instrument`) enables:
- `instrument.coverage.Coverage.endCoverage()`
- `instrument.profiler.Profiler.endProfiler()`
