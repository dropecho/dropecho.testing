# Architecture

## Source Layout

```
src/dropecho/testing/
├── AutoTest.hx            # Build-time entry point (@:build macro target)
├── IncludeTestsMacro.hx  # Main orchestrator — dispatches to framework-specific builders
├── DetectTestLib.hx       # Detects available test framework at compile time
├── BuddyIncludeMacros.hx # Generates TestSuites class for Buddy framework
├── UTestIncludeMacros.hx # Generates TestSuites class for UTest framework
└── Common.hx              # Shared macro utilities: path parsing, file discovery, expr generation

tools/
└── Run.hx                 # haxelib run entry point — CLI test runner across targets
```

## Core Classes

### `AutoTest` (`src/dropecho/testing/AutoTest.hx`)
The only user-facing class. Users set it as their `--main` in their hxml. The `@:build` macro on this class triggers the entire compile-time test discovery pipeline. Has no fields of its own — they are all injected by `IncludeTestsMacro`.

### `IncludeTestsMacro` (`src/dropecho/testing/IncludeTestsMacro.hx`)
Central orchestrator. `buildTests()` is the `@:build` macro entry point:
1. Checks for `dropecho_testing_suite` compiler define (manual override)
2. Calls `DetectTestLib.detectTestLib()`
3. Dispatches to `BuddyIncludeMacros.BuildBuddyMain()` or `UTestIncludeMacros.BuiltUTestMain()`
4. Injects a `main()` field into `AutoTest` that delegates to `TestSuites.main()`

### `DetectTestLib` (`src/dropecho/testing/DetectTestLib.hx`)
Returns `DetectedTestLib` enum: `None | Buddy | UTest`. Uses `haxe.macro.Context.getType()` to probe class availability. Run inside `#if macro` context.

### `BuddyIncludeMacros` (`src/dropecho/testing/BuddyIncludeMacros.hx`)
Generates a synthetic `TestSuites` class whose `main()`:
- Instantiates all discovered `*Tests` classes
- Passes them to `buddy.SuitesRunner`
- Hooks instrumentation shutdown (`#if instrument`)
- Exits with the runner's status code

### `UTestIncludeMacros` (`src/dropecho/testing/UTestIncludeMacros.hx`)
Generates a synthetic `TestSuites` class whose `main()`:
- Creates `utest.Runner`
- Adds each discovered test suite via `runner.addCase()`
- Hooks instrumentation shutdown (`#if instrument`)
- Creates a UI report via `utest.ui.Report.create(runner)`
- Calls `runner.run()`

### `Common` (`src/dropecho/testing/Common.hx`)
Macro-only utilities:
- `extractPath()` — reads `Context.getClassPath()`, filters comments and absolute paths
- `extractTestSuites(root, dir, data)` — recursively walks directories, collects `*Tests.hx` paths
- `extractExpr(base, path)` — converts a filesystem path like `src/foo/BarTests.hx` into a macro `Expr` for `new foo.BarTests()`

### `tools/Run.hx`
Invoked by `haxelib run dropecho.testing`. Reads `.dropecho.testing.json`, compiles using `haxe --main=dropecho.testing.AutoTest <hxml>`, then runs compiled artifacts for each target (js→node, neko, python→python3, hl, etc.). Accumulates exit codes from all targets.

## Compile-Time Data Flow

```
@:build on AutoTest
  → IncludeTestsMacro.buildTests()
    → DetectTestLib.detectTestLib()           # probes for buddy.Buddy or utest.Runner
    → BuddyIncludeMacros.BuildBuddyMain()     # or UTestIncludeMacros.BuiltUTestMain()
      → Common.extractPath()                  # reads compiler classpaths
      → Common.extractTestSuites()            # recursive *Tests.hx file scan
      → Common.extractExpr()                  # path → new Foo.BarTests() expr
      → Context.defineType(TestSuites)        # synthesizes TestSuites class
    → injects main() field into AutoTest
```

## Runtime Data Flow (via tools/Run.hx)

```
haxelib run dropecho.testing
  → Run.main()
    → LoadOrMakeConfig()                      # reads .dropecho.testing.json
    → BuildTests(path)                        # calls: haxe --main=dropecho.testing.AutoTest test.hxml
    → GetTargets(hxmlPath)                    # parses hxml for --js, --neko, etc.
    → for each target: exec runner binary     # node/neko/python3/hl/etc.
    → aggregate + return exit codes
```

## Key Design Patterns

1. **Compile-time metaprogramming** — all test discovery happens before runtime, zero overhead
2. **Dual framework support via detection** — no user configuration needed
3. **Synthetic class generation** — `Context.defineType()` creates `TestSuites` dynamically
4. **Conditional instrumentation** — `#if instrument` guards keep the core dependency-free
5. **Config-file-driven CLI** — `.dropecho.testing.json` controls hxml path and targets
