package dropecho.testing;

import sys.io.Process;
import utest.Assert;

using StringTools;

/** What a compiled fixture printed, and the exit code it ended with. **/
typedef FixtureRun = {
	output:String,
	exitCode:Int,
}

/**
Builds the fixture projects in `test/fixtures` with `AutoTest` as main and checks
what the generated UTest runner prints under each output define.
**/
class ReportModeTests extends utest.Test {
	static inline var SUMMARY = "results:";

	function testDefaultHidesSummaryAndPassingResults() {
		var run = runFixture("passing", []);

		Assert.equals(0, run.exitCode);
		Assert.isFalse(run.output.contains(SUMMARY));
		Assert.isFalse(run.output.contains("testPasses"));
	}

	function testDefaultStillShowsFailures() {
		var run = runFixture("failing", []);

		Assert.equals(1, run.exitCode);
		Assert.isTrue(run.output.contains("testFails: FAILURE"));
		Assert.isFalse(run.output.contains(SUMMARY));
	}

	function testShowHeadersShowsSummaryButHidesPassingResults() {
		var run = runFixture("passing", ["show_headers"]);

		Assert.equals(0, run.exitCode);
		Assert.isTrue(run.output.contains(SUMMARY));
		Assert.isFalse(run.output.contains("testPasses"));
	}

	function testShowHeadersStillShowsFailures() {
		var run = runFixture("failing", ["show_headers"]);

		Assert.equals(1, run.exitCode);
		Assert.isTrue(run.output.contains(SUMMARY));
		Assert.isTrue(run.output.contains("testFails: FAILURE"));
	}

	function testVerboseShowsSummaryAndPassingResults() {
		var run = runFixture("passing", ["verbose"]);

		Assert.equals(0, run.exitCode);
		Assert.isTrue(run.output.contains(SUMMARY));
		Assert.isTrue(run.output.contains("testPasses: OK"));
	}

	function testVerboseWinsOverShowHeaders() {
		var run = runFixture("passing", ["show_headers", "verbose"]);

		Assert.isTrue(run.output.contains("testPasses: OK"));
	}

	function testDiscoversSuitesInSubpackages() {
		var run = runFixture("passing", ["verbose"]);

		Assert.isTrue(run.output.contains("nested.NestedTests"));
		Assert.isTrue(run.output.contains("testNestedPasses: OK"));
	}

	/**
	Compiles and runs one fixture on the eval interpreter.

	@param fixture The folder name under `test/fixtures`.
	@param defines The `-D` flags to build it with.
	@return The fixture's combined output and its exit code.
	**/
	static function runFixture(fixture:String, defines:Array<String>):FixtureRun {
		var args = [
			"--class-path", "src",
			"--class-path", 'test/fixtures/$fixture',
			"--library", "utest",
			"--main", "dropecho.testing.AutoTest",
			"--interp",
		];
		for (define in defines) {
			args = args.concat(["-D", define]);
		}

		var process = new Process("haxe", args);
		var output = process.stdout.readAll().toString() + process.stderr.readAll().toString();
		var exitCode = process.exitCode();
		process.close();

		return {output: output, exitCode: exitCode};
	}
}
