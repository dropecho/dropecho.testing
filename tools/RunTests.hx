package tools;

import utest.Assert;
import utest.Test;

class RunTests extends Test {
	function testParseTargetsSingleJs() {
		var ts = Run.ParseTargets("--js out/tests.js");
		Assert.equals(1, ts.length);
		Assert.equals("js", (ts[0].target : String));
		Assert.equals("out/tests.js", ts[0].path);
	}

	function testParseTargetsSingleNeko() {
		var ts = Run.ParseTargets("--neko out/tests.n");
		Assert.equals(1, ts.length);
		Assert.equals("neko", (ts[0].target : String));
		Assert.equals("out/tests.n", ts[0].path);
	}

	function testParseTargetsSingleDashFormat() {
		var ts = Run.ParseTargets("-js out/tests.js");
		Assert.equals(1, ts.length);
		Assert.equals("js", (ts[0].target : String));
	}

	function testParseTargetsMultiple() {
		var ts = Run.ParseTargets("--js out/tests.js\n--neko out/tests.n");
		Assert.equals(2, ts.length);
	}

	function testParseTargetsIgnoresNonTargetLines() {
		var ts = Run.ParseTargets("# comment\n--class-path src\n--js out/tests.js");
		Assert.equals(1, ts.length);
		Assert.equals("js", (ts[0].target : String));
	}

	function testParseTargetsEmpty() {
		var ts = Run.ParseTargets("");
		Assert.equals(0, ts.length);
	}

	function testParseTargetsIgnoresUnknownTargets() {
		var ts = Run.ParseTargets("--unknown out/tests.bin");
		Assert.equals(0, ts.length);
	}

	function testParseTargetsTrimsPaths() {
		var ts = Run.ParseTargets("--js out/tests.js  ");
		Assert.equals(1, ts.length);
		Assert.equals("out/tests.js", ts[0].path);
	}

	function testParseTargetsWindowsLineEndings() {
		var ts = Run.ParseTargets("--js out/tests.js\r\n--neko out/tests.n\r\n");
		Assert.equals(2, ts.length);
	}

	function testParseTargetsAllSupportedTargets() {
		var content = "--js out/js\n--neko out/neko\n--java out/java\n--python out/py\n--cpp out/cpp\n--cs out/cs\n--php out/php\n--hl out/hl\n--lua out/lua";
		var ts = Run.ParseTargets(content);
		Assert.equals(9, ts.length);
	}
}
