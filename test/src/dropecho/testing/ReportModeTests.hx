package dropecho.testing;

import utest.Assert;

using StringTools;

/**
Builds the fixture projects in `test/fixtures` with `AutoTest` as main and checks
what the generated UTest runner prints under each output define.
**/
class ReportModeTests extends utest.Test {
	static inline var SUMMARY = "results:";

	function testDefaultHidesSummaryAndPassingResults() {
		var run = Fixture.run("passing", []);

		Assert.equals(0, run.exitCode);
		Assert.isFalse(run.output.contains(SUMMARY));
		Assert.isFalse(run.output.contains("testPasses"));
	}

	function testDefaultStillShowsFailures() {
		var run = Fixture.run("failing", []);

		Assert.equals(1, run.exitCode);
		Assert.isTrue(run.output.contains("testFails: FAILURE"));
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
