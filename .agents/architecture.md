# Architecture

## Source Layout

```
src/dropecho/testing/
├── AutoTest.hx            # Build-time entry point (@:build macro target)
├── IncludeTestsMacro.hx  # Main orchestrator — dispatches to framework-specific builders
├── DetectTestLib.hx       # Detects available test framework at compile time
├── BuddyIncludeMacros.hx # Generates TestSuites class for Buddy framework
├── UTestIncludeMacros.hx # Generates TestSuites class for UTest framework
├── UTestReport.hx         # Runtime: prints UTest results per output mode
├── BuddyReporter.hx       # Runtime: prints Buddy results per output mode
├── ReportOutput.hx        # Runtime: printing, summary line and exit shared by both reports
├── Common.hx              # Shared macro utilities: suite discovery and expr generation
└── SuitePaths.hx          # Path rules for discovery (no macro code, unit tested)

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
Returns `DetectedTestLib` enum: `None | Buddy | UTest`. Uses `haxe.macro.Context.getType()` to probe class availability. Run inside `#if macro` context. `-D dropecho_testing_lib=utest|buddy` picks the library; without it, Buddy wins when both are present. An unknown value or a missing library is a compile error.

### `BuddyIncludeMacros` (`src/dropecho/testing/BuddyIncludeMacros.hx`)
Generates a synthetic `TestSuites` class whose `main()`:
- Instantiates all discovered `*Tests` classes
- Passes them to `buddy.SuitesRunner` with a `BuddyReporter`
- Hooks instrumentation shutdown (`#if instrument`)
- Exits with the runner's status code via `ReportOutput.exit`

### `UTestIncludeMacros` (`src/dropecho/testing/UTestIncludeMacros.hx`)
Generates a synthetic `TestSuites` class whose `main()`:
- Creates `utest.Runner`
- Adds each discovered test suite via `runner.addCase()`
- Hooks instrumentation shutdown (`#if instrument`)
- Attaches a `UTestReport` to the runner
- Calls `runner.run()`

### `UTestReport` and `BuddyReporter` (runtime)
The generated runners print through these, so both libraries share the output modes:
- Default: failures, then one line, e.g. `results: ALL TESTS OK (assertions: 2, successes: 2, failures: 0, errors: 0)` or `results: ALL TESTS OK (specs: 2, failures: 0, pending: 0)`
- `show_headers`: a summary block, then failures
- `verbose`: a summary block, then every test
They are guarded by `#if (utest && !macro)` / `#if (buddy && !macro)`, so each compiles only when its library is present. Code that branches on the target (`#if sys`, `#if js`) belongs in these runtime classes: inside `macro { }` reification, `#if` is checked against the macro context, where `sys` is always defined.

### `Common` (`src/dropecho/testing/Common.hx`)
Macro-only utilities:
- `collectSuites()` — runs the steps below for every classpath and returns the suite exprs; both builders call it
- `extractPath()` — reads `Context.getClassPath()`, filters comments and absolute paths (Unix and Windows)
- `extractTestSuites(root, dir, data, ?excludes)` — recursively walks directories, skipping hidden and excluded ones, collects `*Tests.hx` paths
- `extractExpr(base, path)` — converts a filesystem path like `src/foo/BarTests.hx` into a macro `Expr` for `new foo.BarTests()`

### `tools/Run.hx`
Invoked by `haxelib run dropecho.testing`. Reads `.dropecho.testing.json` over the defaults, compiles using `haxe --main dropecho.testing.AutoTest <hxml>`, then runs the compiled output of each target (js→node, neko, python→python3 or python, hl, etc.). Stops with a non-zero exit when the build fails; otherwise returns the last failing target's exit code, or 0.

## Compile-Time Data Flow

```
@:build on AutoTest
  → IncludeTestsMacro.buildTests()
    → DetectTestLib.detectTestLib()           # probes for buddy.Buddy or utest.Runner
    → BuddyIncludeMacros.BuildBuddyMain()     # or UTestIncludeMacros.BuiltUTestMain()
      → Common.collectSuites()                # shared by both builders
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
    → ParseArgs()                             # command (run/setup/help) and --verbose/--show-headers
    → LoadConfig() → MergeConfig()            # .dropecho.testing.json over DefaultConfig()
    → ParseTargets(hxml) → RunnerFor(target)  # parses hxml for --js, --neko, etc.; fails on none or unsupported
    → IsSafeToClean() → CleanPath()           # deletes old output, only inside the project
    → haxe BuildArgs(...)                     # stops here if the build fails
    → for each target: exec runner            # node/neko/python3/hl/etc.
    → return the last failing exit code, or 0
```

## Key Design Patterns

1. **Compile-time metaprogramming** — all test discovery happens before runtime, zero overhead
2. **Dual framework support via detection** — no user configuration needed
3. **Synthetic class generation** — `Context.defineType()` creates `TestSuites` dynamically
4. **Conditional instrumentation** — `#if instrument` guards keep the core dependency-free
5. **Config-file-driven CLI** — `.dropecho.testing.json` controls hxml path and targets
