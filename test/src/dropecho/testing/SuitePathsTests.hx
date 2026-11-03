package dropecho.testing;

import utest.Assert;

/** Unit tests for the path rules test discovery uses, including Windows-style paths. **/
class SuitePathsTests extends utest.Test {
	function testIsScannedAcceptsRelativeClassPaths() {
		Assert.isTrue(SuitePaths.isScanned("src/"));
		Assert.isTrue(SuitePaths.isScanned("./"));
		Assert.isTrue(SuitePaths.isScanned("test\\src\\"));
	}

	function testIsScannedSkipsAbsoluteClassPaths() {
		Assert.isFalse(SuitePaths.isScanned("/usr/share/haxe/std/"));
		Assert.isFalse(SuitePaths.isScanned("C:/HaxeToolkit/haxe/std/"));
		Assert.isFalse(SuitePaths.isScanned("C:\\HaxeToolkit\\haxe\\std\\"));
		Assert.isFalse(SuitePaths.isScanned("\\\\server\\share\\lib\\"));
	}

	function testIsScannedSkipsEmptyAndCommentedEntries() {
		Assert.isFalse(SuitePaths.isScanned(""));
		Assert.isFalse(SuitePaths.isScanned("   "));
		Assert.isFalse(SuitePaths.isScanned("#comment"));
	}

	function testIsSuiteFileNeedsANameBeforeTheSuffix() {
		Assert.isTrue(SuitePaths.isSuiteFile("MathTests.hx"));
		Assert.isFalse(SuitePaths.isSuiteFile("Tests.hx"));
		Assert.isFalse(SuitePaths.isSuiteFile("MathTest.hx"));
		Assert.isFalse(SuitePaths.isSuiteFile("MathTests.hx.bak"));
	}

	function testIsWalkedSkipsHiddenFolders() {
		Assert.isTrue(SuitePaths.isWalked("math"));
		Assert.isFalse(SuitePaths.isWalked(".git"));
	}

	function testParseExcludesNormalizesEntries() {
		Assert.same(["test", "a/b", "c/d"], SuitePaths.parseExcludes(" test/ ,, ./a/b ,c\\d\\"));
	}

	function testParseExcludesReturnsNothingWhenUnset() {
		Assert.same([], SuitePaths.parseExcludes(null));
		Assert.same([], SuitePaths.parseExcludes(""));
	}

	function testIsExcludedMatchesTheFolderAndItsChildren() {
		Assert.isTrue(SuitePaths.isExcluded("test", ["test"]));
		Assert.isTrue(SuitePaths.isExcluded("test/fixtures/", ["test"]));
		Assert.isTrue(SuitePaths.isExcluded("test\\fixtures", ["test"]));
	}

	function testIsExcludedMatchesWholeSegmentsOnly() {
		Assert.isFalse(SuitePaths.isExcluded("testing", ["test"]));
		Assert.isFalse(SuitePaths.isExcluded("src/test", ["test"]));
	}

	function testTypePathBuildsPackageFromFolders() {
		var suite = SuitePaths.typePath("src/", "src/math/geometry/AreaTests.hx");

		Assert.same(["math", "geometry"], suite.pack);
		Assert.equals("AreaTests", suite.name);
	}

	function testTypePathHandlesTheCurrentFolderRoot() {
		var suite = SuitePaths.typePath("./", "./tools/RunTests.hx");

		Assert.same(["tools"], suite.pack);
		Assert.equals("RunTests", suite.name);
	}

	function testTypePathHandlesBackslashes() {
		var suite = SuitePaths.typePath("test\\src\\", "test\\src\\math\\AreaTests.hx");

		Assert.same(["math"], suite.pack);
		Assert.equals("AreaTests", suite.name);
	}

	function testTypePathRejectsFilesOutsideTheRoot() {
		Assert.isNull(SuitePaths.typePath("src/", "other/AreaTests.hx"));
	}
}
