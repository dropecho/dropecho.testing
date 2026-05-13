# Conventions & Patterns

## Test File Naming

- Test files **must** end in `Tests.hx` (e.g., `MathTests.hx`, `ParserTests.hx`)
- Discovery is recursive from any directory on the compiler classpath
- The file's path relative to the classpath root determines the Haxe type path:
  - `src/math/MathTests.hx` → `new math.MathTests()`
  - `src/ParserTests.hx` → `new ParserTests()`

## Haxe Macro Conventions

- All macro code is guarded with `#if macro ... #end`
- Macro-only functions are in classes that are never instantiated at runtime
- `Common.hx` contains reusable macro utilities shared by both framework builders
- `DetectedTestLib` is an enum, not a string — add new framework support there first

## Compiler Defines

| Define | Effect |
|--------|--------|
| `dropecho_testing_suite` | Skips auto-discovery; uses the named type as the test suite instead |
| `instrument` | Enables coverage and profiler shutdown hooks in generated `main()` |

## Configuration File

`.dropecho.testing.json` (project root, created by `haxelib run dropecho.testing setup`):
```json
{
  "hxml": "test.hxml",
  "instrument": {
    "coverage": false,
    "profiler": false,
    "coverage_reporter": "lcov"
  }
}
```

## hxml Conventions

- `test.hxml` is the expected test build file (configurable)
- The hxml must not specify `--main`; that is injected by the CLI runner as `dropecho.testing.AutoTest`
- Target lines like `--js out/js/tests.js` or `--neko out/tests.n` are parsed to determine runner commands

## Target Runner Mapping

| Haxe Target | Runner CLI |
|-------------|------------|
| `js` | `node` |
| `neko` | `neko` |
| `cpp` | direct binary |
| `java` | `java -jar` |
| `cs` | `mono` |
| `python` | `python3` |
| `php` | `php` |
| `hl` | `hl` |
| `lua` | `lua` |

## Release Process

- Uses semantic-release with Angular commit convention
- `main` branch only
- Publishes to Haxelib via `semantic-release-haxelib`
- Updates `README.md`, `package.json`, and `haxelib.json` with version
- Also publishes `tools/Run.hx` as a release asset

## Code Style

- Haxe source follows standard Haxe conventions (PascalCase classes, camelCase fields)
- Abstract enums used for string-backed type-safe constants (see `TargetType`, `TargetRunner` in `Run.hx`)
- No external runtime dependencies — keep it that way
