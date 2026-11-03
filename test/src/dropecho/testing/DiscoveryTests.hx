package dropecho.testing;

import utest.Assert;

using StringTools;

/** Checks which suites `AutoTest` discovers in the `discovery-exclude` fixture. **/
class DiscoveryTests extends utest.Test {
	static inline var FIXTURE = "discovery-exclude";

	function testFindsEverySuiteWithoutExcludes() {
		var run = Fixture.run(FIXTURE, ["verbose"]);

		Assert.equals(0, run.exitCode);
		for (test in ["testRoot", "testExcluded", "testSibling", "testNestedKept", "testNestedExcluded"]) {
			Assert.isTrue(run.output.contains('$test:'), '$test should be discovered');
		}
	}

	function testSkipsHiddenFolders() {
		var run = Fixture.run(FIXTURE, ["verbose"]);

		Assert.equals(0, run.exitCode);
		Assert.isFalse(run.output.contains("testHidden:"));
	}

	function testSkipsExcludedFolders() {
		var run = Fixture.run(FIXTURE, ["verbose", "dropecho_testing_exclude=skipped"]);

		Assert.equals(0, run.exitCode);
		Assert.isFalse(run.output.contains("testExcluded:"));
		Assert.isTrue(run.output.contains("testRoot:"));
		Assert.isTrue(run.output.contains("testNestedKept:"));
	}

	function testMatchesWholeFolderNames() {
		var run = Fixture.run(FIXTURE, ["verbose", "dropecho_testing_exclude=skipped"]);

		Assert.isTrue(run.output.contains("testSibling:"));
		Assert.isTrue(run.output.contains("testNestedExcluded:"));
	}

	function testSkipsNestedExcludedFolders() {
		var run = Fixture.run(FIXTURE, ["verbose", "dropecho_testing_exclude=nested/skipped"]);

		Assert.equals(0, run.exitCode);
		Assert.isFalse(run.output.contains("testNestedExcluded:"));
		Assert.isTrue(run.output.contains("testNestedKept:"));
		Assert.isTrue(run.output.contains("testExcluded:"));
	}

	function testAcceptsSpacesTrailingSlashesAndEmptyEntries() {
		var run = Fixture.run(FIXTURE, ["verbose", "dropecho_testing_exclude= skipped/ ,, nested/skipped/ "]);

		Assert.equals(0, run.exitCode);
		Assert.isFalse(run.output.contains("testExcluded:"));
		Assert.isFalse(run.output.contains("testNestedExcluded:"));
		Assert.isTrue(run.output.contains("testRoot:"));
	}
}
