package dropecho.testing;

import dropecho.testing.Fixture.FixtureRun;
import utest.Assert;

using StringTools;

/**
Checks `-D dropecho_testing_filter` for UTest and Buddy. Each fixture has a failing
`BrokenTests` suite, so a passing filtered run shows the filter left it out.
**/
class FilterTests extends utest.Test {
	function testUTestRunsOnlySuitesWhoseNameMatches() {
		var run = runUTest("MathTests");

		Assert.equals(0, run.exitCode);
		Assert.isTrue(run.stdout.contains("testAdds: OK"));
		Assert.isTrue(run.stdout.contains("testSubtracts: OK"));
		Assert.isFalse(run.stdout.contains("ParserTests"));
	}

	function testUTestMatchesSingleTestNames() {
		var run = runUTest("MathTests.testSubtracts");

		Assert.equals(0, run.exitCode);
		Assert.isTrue(run.stdout.contains("testSubtracts: OK"));
		Assert.isFalse(run.stdout.contains("testAdds"));
	}

	function testUTestMatchesThePackageAndAlternatives() {
		var run = runUTest("parser\\.ParserTests|testAdds");

		Assert.equals(0, run.exitCode);
		Assert.isTrue(run.stdout.contains("testParses: OK"));
		Assert.isTrue(run.stdout.contains("testAdds: OK"));
		Assert.isFalse(run.stdout.contains("testSubtracts"));
	}

	function testUTestFailsWhenNothingMatches() {
		var run = runUTest("Nope");

		Assert.equals(1, run.exitCode);
		Assert.isTrue(run.stdout.contains('No tests matched the filter "Nope".'));
	}

	function testBuddyRunsOnlySuitesWhoseNameMatches() {
		var run = runBuddy("parser.ParserTests");

		Assert.equals(0, run.exitCode);
		Assert.isTrue(run.stdout.contains("parses (Passed)"));
		Assert.isFalse(run.stdout.contains("adds"));
	}

	function testBuddyMatchesDescribeAndItDescriptions() {
		var run = runBuddy("Math subtracts");

		Assert.equals(0, run.exitCode);
		Assert.isTrue(run.stdout.contains("subtracts (Passed)"));
		Assert.isFalse(run.stdout.contains("adds"));
	}

	function testBuddyFailsWhenNothingMatches() {
		var run = runBuddy("Nope");

		Assert.equals(1, run.exitCode);
		Assert.isTrue(run.stdout.contains('No tests matched the filter "Nope".'));
	}

	function testEmptyPatternStopsTheBuild() {
		var run = Fixture.run("filter-utest", ["dropecho_testing_filter="]);

		Assert.notEquals(0, run.exitCode);
		Assert.isTrue(run.output.contains("dropecho_testing_filter needs a pattern"));
	}

	static function runUTest(pattern:String):FixtureRun {
		return Fixture.run("filter-utest", ["verbose", 'dropecho_testing_filter=$pattern']);
	}

	static function runBuddy(pattern:String):FixtureRun {
		return Fixture.run("filter-buddy", ["verbose", 'dropecho_testing_filter=$pattern'], ["buddy"]);
	}
}
