package tools;

import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

@:enum
@:forward
abstract TargetType(String) from String to String {
	var as3 = "as3";
	var js = "js";
	var neko = "neko";
	var cpp = "cpp";
	var java = "java";
	var cs = "cs";
	var python = "python";
	var php = "php";
	var hl = "hl";
	var lua = "lua";
}

@:enum
@:forward
abstract TargetRunner(String) from String to String {
	//   var as3 = "as3";
	var js = "node";
	var neko = "neko";
	var cpp = "cpp";
	//   var java = "java";
	var cs = "";
	var python = "python3";
	//   var php = "php";
	//   var hl = "hl";
	//   var lua = "lua";
}

typedef TargetConfig = {
	target:String,
	path:String
}

typedef RunConfig = {
	instrument:{
		coverage:Bool, profiler:Bool, coverage_reporter:String
	},
	root_package:String,
	hxml:String,
}

class Run {
	static var targets:Array<TargetType> = [js, neko, java, cpp, cs, python, php, hl, lua];
	static var config:RunConfig;

	@run
	public static function main() {
		var args = Sys.args();
		// set CWD to calling dir.
		Sys.setCwd(args.pop());

		config = LoadOrMakeConfig();

		var command = args.length > 0 ? args.pop() : "run";
		var returnCode = 0;

		switch (command) {
			case "setup":
				SetupConfig();
			default:
				returnCode = Run();
		}

		Sys.exit(returnCode);
	}

	static function Run():Int {
		var path = FileSystem.absolutePath(config.hxml);

		if (!FileSystem.exists(path)) {
			throw "Invalid hxml passed to test, default is test.hxml.";
		}

		for (target in GetTargets(path)) {
			CleanPath(target.path);
		}

		BuildTests(path);

		var returnCode = 0;

		for (target in GetTargets(path)) {
			returnCode += RunTests(target);
		}

		return returnCode;
	}

	static function CleanPath(root:String, ?path:String) {
		var p = Path.join([root, path]);

		if (FileSystem.isDirectory(p)) {
			var files = FileSystem.readDirectory(p);
			for (file in files) {
				CleanPath(p, file);
			}
			FileSystem.deleteDirectory(p);
		} else {
			if (FileSystem.exists(p)) {
				FileSystem.deleteFile(p);
			}
		}
	}

	static function BuildTests(path:String) {
		var args = [];

		args.push("--main");
		args.push("dropecho.testing.AutoTest");

		var root_package = config.root_package;

		if (config.instrument != null) {
			args.push("--library");
			args.push("instrument");
			args.push("--define");
			args.push("instrument");
			if (config.instrument.coverage == true) {
				args.push("--macro");
				args.push('instrument.Instrumentation.coverage(["${root_package}"],["src"],[])');
			}

			if (config.instrument.coverage_reporter != null) {
				args.push("--define");
				args.push(config.instrument.coverage_reporter);
			}
		}
		args.push(path);
		Sys.command("haxe", args);
	}

	static function CommandExists(cmd:String):Bool {
		#if windows
		var proc = new sys.io.Process("where", [cmd]);
		#else
		var proc = new sys.io.Process("which", [cmd]);
		#end
		var code = proc.exitCode();
		proc.close();
		return code == 0;
	}

	static function RunTests(target:TargetConfig):Int {
		Sys.stdout().writeString('${target.target} tests:\n');
		Sys.stdout().flush();

		var runner:String;
		var args:Array<String>;

		switch (target.target) {
			case TargetType.neko:
				runner = TargetRunner.neko;
				args = [target.path];
			case TargetType.js:
				runner = TargetRunner.js;
				args = [target.path];
			case TargetType.python:
				runner = TargetRunner.python;
				args = [target.path];
			case TargetType.cs:
				var exe = target.path + "/bin/AutoTest.exe";
				#if windows
				runner = exe;
				args = [target.path];
				#else
				// hxcs produces Mono PE32 assemblies; prefer mono, fall back to dotnet
				runner = CommandExists("mono") ? "mono" : "dotnet";
				args = [exe, target.path];
				#end
			case TargetType.cpp:
				runner = target.path + "/AutoTest";
				args = [target.path];
			default:
				return 0;
		}

		var exitCode = Sys.command(runner, args);

		Sys.stdout().writeString('\n');
		Sys.stdout().flush();

		return exitCode;
	}

	public static function ParseTargets(content:String):Array<TargetConfig> {
		var targetsInHxml = [];
		var lines = content.split("\n");

		for (line in lines) {
			for (target in targets) {
				var matcher = new EReg("^--?" + target.toString() + "\\s+(.*)", "");
				if (matcher.match(line)) {
					targetsInHxml.push({
						target: target,
						path: StringTools.trim(matcher.matched(1))
					});
				}
			}
		}
		return targetsInHxml;
	}

	static function GetTargets(hxml:String):Array<TargetConfig> {
		var content = sys.io.File.getContent(hxml);
		return ParseTargets(content);
	}

	static function SetupConfig() {
		var config = LoadOrMakeConfig();

		var userConfigFile = FileSystem.absolutePath('.dropecho.testing.json');
		File.write(userConfigFile, false).writeString(Json.stringify(config, null, "  "));
	}

	static function LoadOrMakeConfig():RunConfig {
		var userConfigFile = FileSystem.absolutePath('.dropecho.testing.json');
		var config = {
			instrument: null,
			root_package: null,
			hxml: 'test.hxml'
		}

		if (!FileSystem.exists(userConfigFile)) {
			return config;
		}

		var configContent = sys.io.File.getContent(userConfigFile);
		config = Json.parse(configContent);

		return config;
	}
}
