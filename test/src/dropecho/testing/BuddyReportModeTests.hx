package dropecho.testing;

import utest.Assert;

using StringTools;

/**
Builds the Buddy fixture projects with `AutoTest` as main and checks what the
generated Buddy runner prints under each output define.
**/
class BuddyReportModeTests extends utest.Test {
	// Only the summary block's results line has this.
	static inline var SUMMARY = "(success:";
	static var BUDDY = ["buddy"];

	function testDefaultPrintsOnlyAOneLineSummaryWhenAllPass() {
		var run = Fixture.run("buddy-passing", [], BUDDY);
		var lines = run.output.trim().split("\n");

		Assert.equals(0, run.exitCode);
		Assert.equals(1, lines.length);
		Assert.isTrue(lines[0].startsWith("results: ALL TESTS OK"));
		Assert.isTrue(lines[0].contains("specs: 2"));
	}

	function testDefaultShowsOnlyFailedSpecsAndTheSummaryLine() {
		var run = Fixture.run("buddy-failing", [], BUDDY);

		Assert.equals(1, run.exitCode);
		Assert.isTrue(run.output.contains("fails (FAILED)"));
		Assert.isTrue(run.output.contains("Expected false, was true"));
		Assert.isFalse(run.output.contains("passes (Passed)"));
		Assert.isTrue(run.output.contains("results: SOME TESTS FAILURES"));
		Assert.isFalse(run.output.contains(SUMMARY));
	}

	function testShowHeadersShowsSummaryButHidesPassingSpecs() {
		var run = Fixture.run("buddy-passing", ["show_headers"], BUDDY);

		Assert.equals(0, run.exitCode);
		Assert.isTrue(run.output.contains(SUMMARY));
		Assert.isFalse(run.output.contains("(Passed)"));
	}

	function testShowHeadersStillShowsFailures() {
		var run = Fixture.run("buddy-failing", ["show_headers"], BUDDY);

		Assert.equals(1, run.exitCode);
		Assert.isTrue(run.output.contains(SUMMARY));
		Assert.isTrue(run.output.contains("fails (FAILED)"));
		Assert.isFalse(run.output.contains("passes (Passed)"));
	}

	function testVerboseShowsSummaryAndEverySpec() {
		var run = Fixture.run("buddy-failing", ["verbose"], BUDDY);

		Assert.equals(1, run.exitCode);
		Assert.isTrue(run.output.contains(SUMMARY));
		Assert.isTrue(run.output.contains("fails (FAILED)"));
		Assert.isTrue(run.output.contains("passes (Passed)"));
	}

	function testVerboseWinsOverShowHeaders() {
		var run = Fixture.run("buddy-passing", ["show_headers", "verbose"], BUDDY);

		Assert.isTrue(run.output.contains("passes (Passed)"));
	}

	function testDiscoversSuitesInSubpackages() {
		var run = Fixture.run("buddy-passing", ["verbose"], BUDDY);

		Assert.isTrue(run.output.contains("passes too (Passed)"));
	}

	function testPrintsNoProgressDots() {
		var run = Fixture.run("buddy-failing", [], BUDDY);

		Assert.isFalse(run.output.startsWith("X."));
	}
}
