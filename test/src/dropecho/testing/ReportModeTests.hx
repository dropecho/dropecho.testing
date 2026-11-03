package dropecho.testing;

import utest.Assert;

using StringTools;

/**
Builds the fixture projects in `test/fixtures` with `AutoTest` as main and checks
what the generated UTest runner prints under each output define.
**/
class ReportModeTests extends utest.Test {
	// Only the full summary block has this line (utest's own spelling).
	static inline var SUMMARY = "assertations:";

	function testDefaultPrintsOnlyAOneLineSummaryWhenAllPass() {
		var run = Fixture.run("passing", []);
		var lines = run.output.trim().split("\n");

		Assert.equals(0, run.exitCode);
		Assert.equals(1, lines.length);
		Assert.isTrue(lines[0].startsWith("results: ALL TESTS OK"));
		Assert.isTrue(lines[0].contains("assertions: 2"));
	}

	function testDefaultShowsFailuresAndTheSummaryLine() {
		var run = Fixture.run("failing", []);

		Assert.equals(1, run.exitCode);
		Assert.isTrue(run.output.contains("testFails: FAILURE"));
		Assert.isTrue(run.output.contains("results: SOME TESTS FAILURES"));
		Assert.isFalse(run.output.contains(SUMMARY));
	}

	function testShowHeadersShowsSummaryButHidesPassingResults() {
		var run = Fixture.run("passing", ["show_headers"]);

		Assert.equals(0, run.exitCode);
		Assert.isTrue(run.output.contains(SUMMARY));
		Assert.isFalse(run.output.contains("testPasses"));
	}

	function testShowHeadersStillShowsFailures() {
		var run = Fixture.run("failing", ["show_headers"]);

		Assert.equals(1, run.exitCode);
		Assert.isTrue(run.output.contains(SUMMARY));
		Assert.isTrue(run.output.contains("testFails: FAILURE"));
	}

	function testVerboseShowsSummaryAndPassingResults() {
		var run = Fixture.run("passing", ["verbose"]);

		Assert.equals(0, run.exitCode);
		Assert.isTrue(run.output.contains(SUMMARY));
		Assert.isTrue(run.output.contains("testPasses: OK"));
	}

	function testVerboseWinsOverShowHeaders() {
		var run = Fixture.run("passing", ["show_headers", "verbose"]);

		Assert.isTrue(run.output.contains("testPasses: OK"));
	}

	function testDiscoversSuitesInSubpackages() {
		var run = Fixture.run("passing", ["verbose"]);

		Assert.isTrue(run.output.contains("nested.NestedTests"));
		Assert.isTrue(run.output.contains("testNestedPasses: OK"));
	}
}
