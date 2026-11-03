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
| `show_headers` | UTest only: prints the results summary, still hides passing tests |
| `verbose` | UTest only: prints the summary and every passing test (wins over `show_headers`) |

## Configuration File

`.dropecho.testing.json` (project root, created by `haxelib run dropecho.testing setup`). Every field is optional; anything left out uses the default shown:
```json
{
  "hxml": "test.hxml",
  "root_package": null,
  "instrument": {
    "coverage": false,
    "profiler": false,
    "coverage_reporter": null,
    "coverage_paths": ["src"]
  }
}
```

- `instrument` is only added to the build when `coverage` or `profiler` is `true`.
- `root_package` limits instrumentation to one package; `null` instruments everything under `coverage_paths`.
- `coverage_reporter` takes a short name (`lcov`, `console-summary`) or the full define (`coverage-lcov-reporter`).

## CLI

```
haxelib run dropecho.testing [run|setup|help] [--verbose] [--show-headers]
```

- `run` (default) builds the hxml with `--main dropecho.testing.AutoTest` and runs each target.
- `--verbose` / `--show-headers` add `-D verbose` / `-D show_headers` to the build.
- Unknown arguments print usage and exit 1.
- The run exits non-zero when the build fails (nothing runs), when the hxml has no targets, when a target can't be run, or when a target path is outside the project or is the project itself (it is deleted before each build).

## hxml Conventions

- `test.hxml` is the expected test build file (configurable)
- The hxml must not specify `--main`; that is injected by the CLI runner as `dropecho.testing.AutoTest`
- Target lines like `--js out/js/tests.js` or `--neko out/tests.n` are parsed to determine runner commands

## Target Runner Mapping

| Haxe Target | Runner CLI |
|-------------|------------|
| `js` | `node <file>` |
| `neko` | `neko <file>` |
| `cpp` | `<dir>/AutoTest` (`AutoTest.exe` on Windows) |
| `jvm` | `java -jar <file>` |
| `java` | `java -jar <dir>/AutoTest.jar` |
| `cs` | `<dir>/bin/AutoTest.exe` on Windows; otherwise `mono`, or `dotnet` without mono |
| `python` | `python3 <file>` |
| `php` | `php <dir>/index.php` |
| `hl` | `hl <file>` |
| `lua` | `lua <file>` |
| `interp` | none; the tests run during the build |
| `swf`, `as3` | not supported; the run fails |

## Release Process

- Uses semantic-release with Angular commit convention
- `main` branch only
- Publishes to Haxelib via `semantic-release-haxelib`
- Updates `README.md`, `package.json`, and `haxelib.json` with version
- Also publishes `tools/Run.hx` as a release asset

## Dependencies

`instrument` is an **optional peer dependency**. Users who want coverage/profiling must install it themselves (`haxelib install instrument`). It is intentionally absent from `haxelib.json` `dependencies` — adding it there would force all users to install it even when they don't use instrumentation. Haxelib has no formal peer-dep mechanism; the convention here is: not in `dependencies` = peer/optional.

## Code Style

- Haxe source follows standard Haxe conventions (PascalCase classes, camelCase fields)
- Abstract enums used for string-backed type-safe constants (see `TargetType`, `TargetRunner` in `Run.hx`)
- No external runtime dependencies — keep it that way
