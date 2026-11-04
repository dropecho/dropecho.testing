package tools;

import tools.Run;
import utest.Assert;
import utest.Test;

using StringTools;

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

	function testParseTargetsJvm() {
		var ts = Run.ParseTargets("--jvm out/tests.jar");
		Assert.equals(1, ts.length);
		Assert.equals("jvm", (ts[0].target : String));
		Assert.equals("out/tests.jar", ts[0].path);
	}

	function testParseTargetsInterpNeedsNoPath() {
		var ts = Run.ParseTargets("--interp");
		Assert.equals(1, ts.length);
		Assert.equals("interp", (ts[0].target : String));
		Assert.equals("", ts[0].path);
	}

	function testParseTargetsSkipsTargetsWithoutPath() {
		Assert.equals(0, Run.ParseTargets("--js").length);
	}

	function testParseTargetsIgnoresIndentation() {
		var ts = Run.ParseTargets("  --neko out/tests.n");
		Assert.equals(1, ts.length);
	}

	function testParseTargetsIgnoresFlagsThatStartWithATargetName() {
		Assert.equals(0, Run.ParseTargets("--json out.json\n--hlx out").length);
	}

	function testParseArgsDefaultsToRun() {
		var request = requestOf([]);
		Assert.equals(CliCommand.RunTests, request.command);
		Assert.same([], request.defines);
	}

	function testParseArgsTakesFlagsAndCommandInAnyOrder() {
		Assert.same(["verbose"], requestOf(["--verbose", "run"]).defines);
		Assert.same(["show_headers"], requestOf(["run", "--show-headers"]).defines);
	}

	function testParseArgsReadsSetup() {
		Assert.equals(Setup, requestOf(["setup"]).command);
	}

	function testParseArgsReadsHelp() {
		Assert.equals(Help, requestOf(["--help"]).command);
		Assert.equals(Help, requestOf(["-h"]).command);
	}

	function testParseArgsRejectsUnknownArguments() {
		Assert.isTrue(isInvalid(["--verbos"]));
		Assert.isTrue(isInvalid(["test"]));
	}

	function testParseArgsRejectsTwoCommands() {
		Assert.isTrue(isInvalid(["setup", "run"]));
	}

	function testParseArgsRejectsRunFlagsWithSetup() {
		Assert.isTrue(isInvalid(["setup", "--verbose"]));
	}

	function testMergeConfigUsesDefaultsForMissingFields() {
		var config = Run.MergeConfig({root_package: "my.pkg"});
		Assert.equals("test.hxml", config.hxml);
		Assert.equals("my.pkg", config.root_package);
		Assert.isFalse(config.instrument.coverage);
		Assert.same(["src"], config.instrument.coverage_paths);
	}

	function testMergeConfigMergesInsideInstrument() {
		var config = Run.MergeConfig({instrument: {coverage: true}});
		Assert.isTrue(config.instrument.coverage);
		Assert.isFalse(config.instrument.profiler);
		Assert.same(["src"], config.instrument.coverage_paths);
	}

	function testMergeConfigTreatsNullAsMissing() {
		var config = Run.MergeConfig({hxml: null, instrument: null});
		Assert.equals("test.hxml", config.hxml);
		Assert.isFalse(config.instrument.coverage);
	}

	function testInstrumentArgsAreEmptyWhenCoverageAndProfilerAreOff() {
		var config = Run.MergeConfig({instrument: {coverage: false, profiler: false, coverage_reporter: "lcov"}});
		Assert.same([], Run.InstrumentArgs(config));
	}

	function testInstrumentArgsCoverEverythingInSourcePathsWithoutRootPackage() {
		var args = Run.InstrumentArgs(Run.MergeConfig({instrument: {coverage: true}}));
		Assert.contains("instrument", args);
		Assert.contains('instrument.Instrumentation.coverage([""], ["src"], [])', args);
		Assert.isFalse(args.join(" ").contains("null"));
	}

	function testInstrumentArgsUseRootPackageAndCoveragePaths() {
		var config = Run.MergeConfig({root_package: "my.pkg", instrument: {coverage: true, coverage_paths: ["lib"]}});
		Assert.contains('instrument.Instrumentation.coverage(["my.pkg"], ["lib"], [])', Run.InstrumentArgs(config));
	}

	function testInstrumentArgsAddTheReporterDefine() {
		var config = Run.MergeConfig({instrument: {coverage: true, coverage_reporter: "lcov"}});
		Assert.contains("coverage_lcov_reporter", Run.InstrumentArgs(config));
	}

	function testInstrumentArgsTurnOnProfilingOnly() {
		var args = Run.InstrumentArgs(Run.MergeConfig({instrument: {profiler: true}}));
		Assert.contains('instrument.Instrumentation.profiling([""], ["src"], [])', args);
		Assert.isFalse(args.join(" ").contains("coverage("));
	}

	function testReporterDefineExpandsShortNames() {
		Assert.equals("coverage_lcov_reporter", Run.ReporterDefine("lcov"));
		Assert.equals("coverage_console_summary_reporter", Run.ReporterDefine("console-summary"));
	}

	function testReporterDefineKeepsFullDefines() {
		Assert.equals("coverage_lcov_reporter", Run.ReporterDefine("coverage-lcov-reporter"));
	}

	function testBuildArgsPutDefinesBeforeTheHxml() {
		var args = Run.BuildArgs(Run.DefaultConfig(), "/proj/test.hxml", ["verbose"]);
		Assert.same(["--main", "dropecho.testing.AutoTest", "--define", "verbose", "/proj/test.hxml"], args);
	}

	function testIsSafeToCleanAllowsPathsInsideTheProject() {
		Assert.isTrue(Run.IsSafeToClean("/proj", "out/tests.js"));
		Assert.isTrue(Run.IsSafeToClean("/proj/", "/proj/out"));
		Assert.isTrue(Run.IsSafeToClean("/proj", "../proj/out"));
	}

	function testIsSafeToCleanRefusesTheProjectItself() {
		Assert.isFalse(Run.IsSafeToClean("/proj", "."));
		Assert.isFalse(Run.IsSafeToClean("/proj", "./"));
		Assert.isFalse(Run.IsSafeToClean("/proj", "out/.."));
	}

	function testIsSafeToCleanRefusesPathsOutsideTheProject() {
		Assert.isFalse(Run.IsSafeToClean("/proj", ".."));
		Assert.isFalse(Run.IsSafeToClean("/proj", "/"));
		Assert.isFalse(Run.IsSafeToClean("/proj", "/tmp/out"));
		Assert.isFalse(Run.IsSafeToClean("/proj", "../proj-other/out"));
	}

	function testRunnerForRunsEachTarget() {
		assertCommand("node", ["out/t.js"], target(js, "out/t.js"));
		assertCommand("hl", ["out/t.hl"], target(hl, "out/t.hl"));
		assertCommand("lua", ["out/t.lua"], target(lua, "out/t.lua"));
		assertCommand("php", ["out/php/index.php"], target(php, "out/php"));
		assertCommand("java", ["-jar", "out/t.jar"], target(jvm, "out/t.jar"));
		assertCommand("java", ["-jar", "out/java/AutoTest.jar"], target(java, "out/java"));
	}

	function testRunnerForCppAddsExeOnWindows() {
		assertCommand("out/cpp/AutoTest.exe", ["out/cpp"], target(cpp, "out/cpp"), true);
		assertCommand("out/cpp/AutoTest", ["out/cpp"], target(cpp, "out/cpp"));
	}

	function testRunnerForCsPrefersMonoOffWindows() {
		assertCommand("mono", ["out/cs/bin/AutoTest.exe", "out/cs"], target(cs, "out/cs"), false, true);
		assertCommand("dotnet", ["out/cs/bin/AutoTest.exe", "out/cs"], target(cs, "out/cs"), false, false);
	}

	function testRunnerForInterpRanDuringTheBuild() {
		Assert.isTrue(Run.RunnerFor(target(interp, ""), false, false) == RanDuringBuild);
	}

	function testRunnerForFlashIsUnsupported() {
		Assert.isTrue(Run.RunnerFor(target(swf, "out/t.swf"), false, false) == Unsupported);
		Assert.isTrue(Run.RunnerFor(target(as3, "out/as3"), false, false) == Unsupported);
	}

	static function target(type:TargetType, path:String):TargetConfig {
		return {target: type, path: path};
	}

	static function assertCommand(runner:String, args:Array<String>, target:TargetConfig, isWindows = false, hasMono = false, ?pos:haxe.PosInfos) {
		switch (Run.RunnerFor(target, isWindows, hasMono)) {
			case Command(actualRunner, actualArgs):
				Assert.equals(runner, actualRunner, pos);
				Assert.same(args, actualArgs, pos);
			case other:
				Assert.fail('Expected a command, got $other', pos);
		}
	}

	static function requestOf(args:Array<String>):CliRequest {
		return switch (Run.ParseArgs(args)) {
			case Parsed(request):
				request;
			case Invalid(message):
				throw 'Expected valid args, got: $message';
		}
	}

	static function isInvalid(args:Array<String>):Bool {
		return switch (Run.ParseArgs(args)) {
			case Invalid(_):
				true;
			case Parsed(_):
				false;
		}
	}
}
