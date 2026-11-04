package tools;

import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

using Lambda;
using StringTools;

/** A Haxe output target that can appear in the test hxml. **/
@:forward
enum abstract TargetType(String) from String to String {
	var js = "js";
	var neko = "neko";
	var cpp = "cpp";
	var java = "java";
	var jvm = "jvm";
	var cs = "cs";
	var python = "python";
	var php = "php";
	var hl = "hl";
	var lua = "lua";
	var interp = "interp";
	var swf = "swf";
	var as3 = "as3";
}

/** The programs used to run a compiled target. **/
enum abstract TargetRunner(String) to String {
	var node = "node";
	var neko = "neko";
	var python = "python3";
	var java = "java";
	var php = "php";
	var hl = "hl";
	var lua = "lua";
	var mono = "mono";
	var dotnet = "dotnet";
}

/** How to run one target's compiled tests. **/
enum TargetRun {
	Command(runner:String, args:Array<String>);
	RanDuringBuild;
	Unsupported;
}

/** A target line from the hxml, such as `--js out/tests.js`. **/
typedef TargetConfig = {
	target:TargetType,
	path:String
}

/** The `instrument` section of `.dropecho.testing.json`. **/
typedef InstrumentConfig = {
	coverage:Bool,
	profiler:Bool,
	coverage_reporter:Null<String>,
	coverage_paths:Array<String>,
}

/** The settings in `.dropecho.testing.json`. **/
typedef RunConfig = {
	instrument:InstrumentConfig,
	root_package:Null<String>,
	hxml:String,
}

/** What the CLI was asked to do. **/
enum CliCommand {
	RunTests;
	Setup;
	Help;
}

/** A valid CLI call: the command and the defines to build with. **/
typedef CliRequest = {
	command:CliCommand,
	defines:Array<String>,
}

/** The result of reading the CLI arguments. **/
enum ParsedArgs {
	Parsed(request:CliRequest);
	Invalid(message:String);
}

/** The `haxelib run dropecho.testing` CLI: builds the test hxml with `AutoTest` and runs each target. **/
class Run {
	static inline var MAIN = "dropecho.testing.AutoTest";
	static inline var MAIN_CLASS = "AutoTest";
	static inline var CONFIG_FILE = ".dropecho.testing.json";
	static inline var FILTER_DEFINE = "dropecho_testing_filter";

	static final targets:Array<TargetType> = [js, neko, java, jvm, cpp, cs, python, php, hl, lua, interp, swf, as3];

	static final USAGE = [
		"Usage: haxelib run dropecho.testing [command] [options]",
		"",
		"Commands:",
		"  run             Build the test hxml with AutoTest and run every target in it (default).",
		"  setup           Write .dropecho.testing.json with the default settings.",
		"  help            Show this message.",
		"",
		"Options for run:",
		"  --verbose       Show the summary and every passing test (-D verbose).",
		"  --show-headers  Show the summary but hide passing tests (-D show_headers).",
		"  --filter <re>   Run only tests whose full name matches the regular expression",
		"                  (-D dropecho_testing_filter). Fails when nothing matches.",
	].join("\n");

	public static function main() {
		var args = Sys.args();
		// haxelib (and lix's haxelib shim) append the caller's directory as the last argument.
		if (Sys.getEnv("HAXELIB_RUN") == "1" && args.length > 0) {
			Sys.setCwd(args.pop());
		}
		Sys.exit(Execute(args));
	}

	/**
	Runs the command the arguments ask for.

	@param args The CLI arguments, without the caller's directory.
	@return The process exit code.
	**/
	static function Execute(args:Array<String>):Int {
		var request = switch (ParseArgs(args)) {
			case Invalid(message):
				Sys.stderr().writeString('$message\n\n$USAGE\n');
				return 1;
			case Parsed(request):
				request;
		}

		if (request.command == Help) {
			Sys.println(USAGE);
			return 0;
		}

		var config = try {
			LoadConfig();
		} catch (e) {
			return Fail('Could not read $CONFIG_FILE: ${e.message}');
		}

		return switch (request.command) {
			case Setup:
				File.saveContent(FileSystem.absolutePath(CONFIG_FILE), Json.stringify(config, null, "  "));
				0;
			case _:
				RunAll(config, request.defines);
		}
	}

	/**
	Reads the CLI arguments. Commands and flags may come in any order.

	@param args The CLI arguments, without the caller's directory.
	@return The command and defines, or why the arguments are invalid.
	**/
	public static function ParseArgs(args:Array<String>):ParsedArgs {
		var command:Null<CliCommand> = null;
		var defines = [];
		var filter:Null<String> = null;

		var i = 0;
		while (i < args.length) {
			var arg = args[i];
			i++;

			var next:Null<CliCommand> = null;
			var filterValue:Null<String> = null;
			switch (arg) {
				case "--verbose":
					defines.push("verbose");
				case "--show-headers":
					defines.push("show_headers");
				case "--filter":
					if (i >= args.length) {
						return Invalid("--filter needs a pattern, such as --filter MathTests.");
					}
					filterValue = args[i];
					i++;
				case _ if (arg.startsWith("--filter=")):
					filterValue = arg.substr("--filter=".length);
				case "help" | "--help" | "-h":
					return Parsed({command: Help, defines: []});
				case "setup":
					next = Setup;
				case "run":
					next = RunTests;
				case _:
					return Invalid('Unknown argument: $arg');
			}

			if (filterValue != null) {
				if (filter != null) {
					return Invalid("Give --filter only once. To match several names, use one pattern such as A|B.");
				}
				if (filterValue.length == 0 || filterValue.startsWith("--")) {
					return Invalid("--filter needs a pattern, such as --filter MathTests.");
				}
				filter = filterValue;
				defines.push('$FILTER_DEFINE=$filterValue');
			}

			if (next != null) {
				if (command != null && command != next) {
					return Invalid("Give only one command.");
				}
				command = next;
			}
		}

		if (command == Setup && defines.length > 0) {
			return Invalid("--verbose, --show-headers and --filter only apply to run.");
		}

		return Parsed({command: command != null ? command : RunTests, defines: defines});
	}

	/**
	Builds the tests and runs every target in the hxml.

	@param config The project settings.
	@param defines Extra defines to build with.
	@return 0 when every target passed, otherwise the last failing exit code.
	**/
	static function RunAll(config:RunConfig, defines:Array<String>):Int {
		var hxmlPath = FileSystem.absolutePath(config.hxml);
		if (!FileSystem.exists(hxmlPath)) {
			return Fail('Could not find ${config.hxml}. Create it, or set "hxml" in $CONFIG_FILE.');
		}

		var found = ParseTargets(File.getContent(hxmlPath));
		if (found.length == 0) {
			return Fail('No targets found in ${config.hxml}. Add one, such as --neko artifacts/tests.n.');
		}

		var isWindows = Sys.systemName() == "Windows";
		var hasMono = found.exists(t -> t.target == cs) && CommandExists("mono", isWindows);
		var runs = [for (target in found) RunnerFor(target, isWindows, hasMono)];

		for (i in 0...found.length) {
			if (runs[i] == Unsupported) {
				return Fail('Can\'t run ${found[i].target} tests: there is no runner for that target.');
			}
		}

		var root = Sys.getCwd();
		for (target in found) {
			if (target.path != "" && !IsSafeToClean(root, target.path)) {
				return Fail('Refusing to clean "${target.path}": a target path must be inside the project, not the project itself.');
			}
		}
		for (target in found) {
			if (target.path != "") {
				CleanPath(target.path);
			}
		}

		var buildCode = Sys.command("haxe", BuildArgs(config, hxmlPath, defines));
		if (buildCode != 0) {
			return Fail('Build failed with exit code $buildCode, so no tests were run.', buildCode);
		}

		var result = 0;
		for (i in 0...found.length) {
			var code = RunTarget(found[i], runs[i]);
			if (code != 0) {
				result = code;
			}
		}
		return result;
	}

	/**
	Prints an error to stderr.

	@param message What went wrong.
	@param code The exit code to return.
	@return `code`, so callers can `return Fail(...)`.
	**/
	static function Fail(message:String, code:Int = 1):Int {
		Sys.stderr().writeString('dropecho.testing: $message\n');
		return code;
	}

	/**
	Lists the `haxe` arguments that build the tests.

	@param config The project settings.
	@param hxmlPath The test hxml to build.
	@param defines Extra defines to build with.
	@return The arguments, with the hxml last.
	**/
	public static function BuildArgs(config:RunConfig, hxmlPath:String, defines:Array<String>):Array<String> {
		var args = ["--main", MAIN].concat(InstrumentArgs(config));
		for (define in defines) {
			args = args.concat(["--define", define]);
		}
		args.push(hxmlPath);
		return args;
	}

	/**
	Lists the arguments that turn on coverage and profiling.

	When `root_package` is unset, everything under `coverage_paths` is instrumented.

	@param config The project settings.
	@return The arguments, or none when coverage and profiling are both off.
	**/
	public static function InstrumentArgs(config:RunConfig):Array<String> {
		var instrument = config.instrument;
		if (!instrument.coverage && !instrument.profiler) {
			return [];
		}

		var args = ["--library", "instrument", "--define", "instrument"];
		var packages = config.root_package != null ? [config.root_package] : [""];
		var filters = Json.stringify(packages) + ", " + Json.stringify(instrument.coverage_paths) + ", []";

		if (instrument.coverage) {
			args = args.concat(["--macro", 'instrument.Instrumentation.coverage($filters)']);
			if (instrument.coverage_reporter != null) {
				args = args.concat(["--define", ReporterDefine(instrument.coverage_reporter)]);
			}
		}
		if (instrument.profiler) {
			args = args.concat(["--macro", 'instrument.Instrumentation.profiling($filters)']);
		}
		return args;
	}

	/**
	Turns a reporter name into the define the instrument library reads.

	@param reporter A short name such as `lcov`, or a full define such as `coverage-lcov-reporter`.
	@return The define, such as `coverage_lcov_reporter`.
	**/
	public static function ReporterDefine(reporter:String):String {
		var name = reporter.trim().replace("-", "_");
		return name.startsWith("coverage_") ? name : 'coverage_${name}_reporter';
	}

	/**
	Checks that deleting a target path can't remove the project or anything outside it.

	@param root The project directory.
	@param target The target path from the hxml, absolute or relative to `root`.
	@return True when `target` is strictly inside `root`.
	**/
	public static function IsSafeToClean(root:String, target:String):Bool {
		var base = Path.removeTrailingSlashes(Path.normalize(root));
		var full = Path.isAbsolute(target) ? target : Path.join([base, target]);
		full = Path.removeTrailingSlashes(Path.normalize(full));
		return full.startsWith(base + "/");
	}

	/**
	Deletes a file, or a directory and everything in it.

	@param root The path to delete.
	@param path A path inside `root`, used while recursing.
	**/
	static function CleanPath(root:String, ?path:String) {
		var p = Path.join([root, path]);

		if (FileSystem.isDirectory(p)) {
			for (file in FileSystem.readDirectory(p)) {
				CleanPath(p, file);
			}
			FileSystem.deleteDirectory(p);
		} else if (FileSystem.exists(p)) {
			FileSystem.deleteFile(p);
		}
	}

	/**
	Checks whether a program is on the PATH.

	@param cmd The program name.
	@param isWindows Whether to look it up with `where` instead of `which`.
	@return True when the program was found.
	**/
	static function CommandExists(cmd:String, isWindows:Bool):Bool {
		var proc = new sys.io.Process(isWindows ? "where" : "which", [cmd]);
		var code = proc.exitCode();
		proc.close();
		return code == 0;
	}

	/**
	Picks the program and arguments that run one target's compiled tests.

	@param target The target line from the hxml.
	@param isWindows Whether the tests run on Windows.
	@param hasMono Whether `mono` is installed, for C#.
	@return The command, `RanDuringBuild` for `--interp`, or `Unsupported`.
	**/
	public static function RunnerFor(target:TargetConfig, isWindows:Bool, hasMono:Bool):TargetRun {
		var path = target.path;
		return switch (target.target) {
			case js:
				Command(TargetRunner.node, [path]);
			case neko:
				Command(TargetRunner.neko, [path]);
			case python:
				Command(TargetRunner.python, [path]);
			case hl:
				Command(TargetRunner.hl, [path]);
			case lua:
				Command(TargetRunner.lua, [path]);
			case php:
				Command(TargetRunner.php, [Path.join([path, "index.php"])]);
			case jvm:
				Command(TargetRunner.java, ["-jar", path]);
			case java:
				Command(TargetRunner.java, ["-jar", Path.join([path, '$MAIN_CLASS.jar'])]);
			case cpp:
				Command(Path.join([path, isWindows ? '$MAIN_CLASS.exe' : MAIN_CLASS]), [path]);
			case cs:
				var exe = Path.join([path, "bin", '$MAIN_CLASS.exe']);
				if (isWindows) {
					Command(exe, [path]);
				} else {
					// hxcs produces Mono PE32 assemblies; prefer mono, fall back to dotnet.
					Command(hasMono ? TargetRunner.mono : TargetRunner.dotnet, [exe, path]);
				}
			case interp:
				RanDuringBuild;
			case _:
				Unsupported;
		}
	}

	/**
	Runs one target's compiled tests.

	@param target The target line from the hxml.
	@param run How to run it.
	@return The runner's exit code.
	**/
	static function RunTarget(target:TargetConfig, run:TargetRun):Int {
		Sys.println('${target.target} tests:');

		var exitCode = switch (run) {
			case Command(runner, args):
				Sys.command(runner, args);
			case RanDuringBuild | Unsupported:
				0;
		}

		Sys.println("");
		return exitCode;
	}

	/**
	Reads the targets from an hxml's contents.

	@param content The hxml text.
	@return Each target line, in order.
	**/
	public static function ParseTargets(content:String):Array<TargetConfig> {
		var found = [];
		var whitespace = ~/\s+/;

		for (rawLine in content.split("\n")) {
			var line = rawLine.trim();
			if (!line.startsWith("-")) {
				continue;
			}

			var flag = line;
			var path = "";
			if (whitespace.match(line)) {
				flag = whitespace.matchedLeft();
				path = whitespace.matchedRight().trim();
			}

			var name = flag.startsWith("--") ? flag.substr(2) : flag.substr(1);
			var target = targets.find(t -> t == name);
			if (target == null || (path == "" && target != interp)) {
				continue;
			}
			found.push({target: target, path: path});
		}
		return found;
	}

	/**
	The default settings, used for anything `.dropecho.testing.json` leaves out.

	@return A fresh copy of the defaults.
	**/
	public static function DefaultConfig():RunConfig {
		return {
			hxml: "test.hxml",
			root_package: null,
			instrument: {
				coverage: false,
				profiler: false,
				coverage_reporter: null,
				coverage_paths: ["src"],
			},
		};
	}

	/**
	Lays the user's settings over the defaults, field by field.

	@param user The parsed `.dropecho.testing.json`, or null.
	@return The full settings.
	**/
	public static function MergeConfig(user:Dynamic):RunConfig {
		var config = DefaultConfig();
		if (user == null) {
			return config;
		}

		config.hxml = ValueOr(user, "hxml", config.hxml);
		config.root_package = ValueOr(user, "root_package", config.root_package);

		var instrument:Dynamic = Reflect.field(user, "instrument");
		if (instrument != null) {
			var defaults = config.instrument;
			config.instrument = {
				coverage: ValueOr(instrument, "coverage", defaults.coverage),
				profiler: ValueOr(instrument, "profiler", defaults.profiler),
				coverage_reporter: ValueOr(instrument, "coverage_reporter", defaults.coverage_reporter),
				coverage_paths: ValueOr(instrument, "coverage_paths", defaults.coverage_paths),
			};
		}
		return config;
	}

	/**
	Reads a field, falling back when it is missing or null.

	@param source The object to read.
	@param field The field name.
	@param fallback The value to use when the field is missing or null.
	@return The field's value or `fallback`.
	**/
	static function ValueOr<T>(source:Dynamic, field:String, fallback:T):T {
		var value:Null<T> = Reflect.field(source, field);
		return value != null ? value : fallback;
	}

	/**
	Loads `.dropecho.testing.json` from the current directory.

	@return The settings, with defaults for anything missing.
	**/
	static function LoadConfig():RunConfig {
		var path = FileSystem.absolutePath(CONFIG_FILE);
		if (!FileSystem.exists(path)) {
			return DefaultConfig();
		}
		return MergeConfig(Json.parse(File.getContent(path)));
	}
}
