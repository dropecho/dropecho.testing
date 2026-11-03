package dropecho.testing;

import utest.Assert;

using StringTools;

/** Checks which test library `AutoTest` generates a runner for. **/
class TestLibChoiceTests extends utest.Test {
	static var BOTH = ["buddy", "utest"];

	function testPrefersBuddyWhenBothAreOnTheClasspath() {
		var run = Fixture.run("buddy-passing", [], BOTH);

		Assert.equals(0, run.exitCode);
		Assert.isTrue(run.output.contains("specs: 2"));
	}

	function testUsesUTestWhenAskedForWithBothOnTheClasspath() {
		var run = Fixture.run("passing", ["dropecho_testing_lib=utest"], BOTH);

		Assert.equals(0, run.exitCode);
		Assert.isTrue(run.output.contains("assertions: 2"));
	}

	function testUsesBuddyWhenAskedForWithBothOnTheClasspath() {
		var run = Fixture.run("buddy-passing", ["dropecho_testing_lib=buddy"], BOTH);

		Assert.equals(0, run.exitCode);
		Assert.isTrue(run.output.contains("specs: 2"));
	}

	function testAcceptsAnyCase() {
		var run = Fixture.run("passing", ["dropecho_testing_lib=UTest"], BOTH);

		Assert.equals(0, run.exitCode);
		Assert.isTrue(run.output.contains("assertions: 2"));
	}

	function testRejectsAnUnknownLibraryAndListsTheValidOnes() {
		var run = Fixture.run("passing", ["dropecho_testing_lib=munit"], BOTH);

		Assert.notEquals(0, run.exitCode);
		Assert.isTrue(run.output.contains("munit"));
		Assert.isTrue(run.output.contains("buddy, utest"));
	}

	function testRejectsALibraryThatIsNotOnTheClasspath() {
		var run = Fixture.run("passing", ["dropecho_testing_lib=buddy"], ["utest"]);

		Assert.notEquals(0, run.exitCode);
		Assert.isTrue(run.output.contains("--library buddy"));
	}

	function testReportsWhenNoLibraryIsOnTheClasspath() {
		var run = Fixture.run("passing", [], []);

		Assert.notEquals(0, run.exitCode);
		Assert.isTrue(run.output.contains("--library utest or --library buddy"));
	}
}
