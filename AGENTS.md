# Agent Guide — dropecho.testing

This repository is a Haxe library providing zero-configuration compile-time test discovery for the Buddy and UTest frameworks.

## Documentation

- [Overview](.agents/overview.md) — What the library does, supported frameworks, package metadata
- [Architecture](.agents/architecture.md) — Source layout, class responsibilities, compile-time and runtime data flows
- [Conventions](.agents/conventions.md) — Test file naming, compiler defines, config format, target runner mapping, release process
- [Development](.agents/development.md) — How to build, test, extend framework/target support, and release

## Quick Reference

| File | Role |
|------|------|
| `src/dropecho/testing/AutoTest.hx` | User-facing entry point; `@:build` triggers all macro machinery |
| `src/dropecho/testing/IncludeTestsMacro.hx` | Orchestrates detection and code generation |
| `src/dropecho/testing/DetectTestLib.hx` | Probes classpath for Buddy or UTest at compile time |
| `src/dropecho/testing/BuddyIncludeMacros.hx` | Generates `TestSuites` class for Buddy |
| `src/dropecho/testing/UTestIncludeMacros.hx` | Generates `TestSuites` class for UTest |
| `src/dropecho/testing/Common.hx` | Shared macro utilities (path parsing, file discovery, expr generation) |
| `tools/Run.hx` | `haxelib run` CLI — compiles and executes tests across targets |
| `test.hxml` | Test build config (empty; populated per-project) |
| `build.hxml` | Library build config |
| `.dropecho.testing.json` | Runtime config for the CLI runner (created by `setup` command) |
| `.releaserc.json` | Semantic-release config |

## Key Facts for Agents

- **Language**: Haxe (`.hx` files). Use the `haxe` skill when reading or writing Haxe/hxml files.
- **No runtime dependencies** — keep it that way. Framework detection is compile-time only.
- **Test discovery is compile-time** — changes to `Common.hx` or the `*IncludeMacros` files affect what Haxe generates, not what runs.
- **Macro code** must be inside `#if macro ... #end` and cannot reference runtime-only APIs.
- **Test files** must end in `Tests.hx` to be discovered.
- **Releases** are automated via semantic-release on `main`; follow Angular commit convention.
