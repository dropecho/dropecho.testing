# dropecho.testing

Finds your Haxe tests for you. Point a test build at `dropecho.testing.AutoTest` and every
`*Tests.hx` class on the classpath runs, using [utest](https://github.com/haxe-utest/utest)
or [buddy](https://github.com/ciscoheat/buddy). There's no list of suites to maintain.

## Install

```sh
haxelib install dropecho.testing
# or
lix install haxelib:dropecho.testing
```

Also install utest or buddy.

## Set up

1. Name test files so they end in `Tests.hx`, such as `test/MathTests.hx` or
   `test/parser/ParserTests.hx`. The package must match the folder.

   ```haxe
   class MathTests extends utest.Test {
   	function testAdds() {
   		utest.Assert.equals(4, 2 + 2);
   	}
   }
   ```

2. Create `test.hxml`, without a `--main`:

   ```hxml
   --class-path src
   --class-path test
   --library dropecho.testing
   --library utest

   --neko artifacts/tests.n
   ```

## Run

```sh
haxelib run dropecho.testing
```

This builds `test.hxml`, runs each target it lists, and exits non-zero if a build or test
fails. Supported targets: neko, js (node), python, cpp, cs, java, jvm, php, hl and lua.

To build without the CLI, add the main class yourself:

```sh
haxe --main dropecho.testing.AutoTest test.hxml && neko artifacts/tests.n
```

To test on several targets, separate them with `--each` and `--next`:

```hxml
--class-path test
--library dropecho.testing
--library utest
--each

--next
--neko artifacts/tests.n

--next
--js artifacts/tests.js
```

### CLI options

| Option | Effect |
|---|---|
| `--verbose` | Print a summary and every test |
| `--show-headers` | Print a summary and only failing tests |
| `--filter <pattern>` | Run only tests whose full name matches (see `dropecho_testing_filter`) |
| `setup` | Write a `.dropecho.testing.json` with the defaults |
| `help` | Show usage |

## Output

By default a run prints only failures and a one-line summary:

```
results: ALL TESTS OK (assertions: 12, successes: 12, failures: 0, errors: 0)
```

## Compiler defines

Add these to `test.hxml` (`--define verbose`) or pass them to `haxe` (`-D verbose`).

| Define | Effect |
|---|---|
| `verbose` | Print a summary and every test |
| `show_headers` | Print a summary and only failing tests |
| `dropecho_testing_exclude=a,b` | Skip these folders when looking for tests. Paths are relative to each classpath, e.g. `test/fixtures,node_modules` |
| `dropecho_testing_lib=utest` | Choose `utest` or `buddy` when both are installed (buddy otherwise) |
| `dropecho_testing_suite=my.Suite` | Skip discovery and run `my.Suite.main()` instead |
| `dropecho_testing_filter=<pattern>` | Run only tests whose full name matches this regular expression. The run fails if nothing matches |

### Filtering tests

The pattern is a regular expression searched anywhere in each test's full name:

- utest: `package.ClassName.testName`, e.g. `parser.ParserTests.testParses`
- buddy: `package.ClassName.` followed by the `describe` and `it` texts joined by spaces,
  e.g. `MathTests.Math adds`

So `MathTests` runs one class with either library, and `Math|Parser` runs both.

## Config file

`haxelib run dropecho.testing` reads an optional `.dropecho.testing.json` in the project
root. Any field you leave out uses the default.

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

Coverage and profiling use the [instrument](https://lib.haxe.org/p/instrument) library,
which you install separately. `coverage_reporter` takes a reporter name such as `lcov`.

## License

MIT
