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
	//   var cpp = "cpp";
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
	hxml:String,
}

class Run {
	static var targets:Array<TargetType> = [js, neko, java, cpp, cs, python, php, hl, lua];
	static var config:RunConfig;

	public static function main() {
		var args = Sys.args();
		// set CWD to calling dir.
		Sys.setCwd(args.pop());

		config = LoadOrMakeConfig();

		var command = args.length > 0 ? args.pop() : "run";

		switch (command) {
			case "setup":
				SetupConfig();
			default:
				Run();
		}
	}

	static function Run() {
		var path = FileSystem.absolutePath(config.hxml);

		if (!FileSystem.exists(path)) {
			throw "Invalid hxml passed to test, default is test.hxml.";
		}

		for (target in GetTargets(path)) {
			CleanPath(target.path);
		}

		BuildTests(path);

		for (target in GetTargets(path)) {
			RunTests(target);
		}
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

		args.push("--main=dropecho.testing.AutoTest");

		//     if (config.instrument != null) {
		//       args.push("--library=instrument");
		//       if (config.instrument.coverage == true) {
		//         args.push('--macro=instrument.Instrumentation.coverage(["dropecho"],["src"],[])');
		//       }
		//
		//       if (config.instrument.coverage_reporter != null) {
		//         args.push('--define=' + config.instrument.coverage_reporter);
		//       }
		//     }
		args.push(path);
		Sys.command("haxe", args);
	}

	static function RunTests(target:TargetConfig) {
		Sys.stdout().writeString('${target.target} tests:\n');
		Sys.stdout().flush();
		var runnerName = switch (target.target) {
			case TargetType.neko: TargetRunner.neko;
			case TargetType.js: TargetRunner.js;
			case TargetType.python: TargetRunner.python;
			case TargetType.cs: target.path + "/bin/AutoTest.exe";
			default: return;
		}

		Sys.command(runnerName, [target.path]);
	}

	static function GetTargets(hxml:String):Array<TargetConfig> {
		var targetsInHxml = [];
		var content = sys.io.File.getContent(hxml);
		var lines = content.split("\n");

		for (line in lines) {
			for (target in targets) {
				var matcher = new EReg("^--?" + target.toString() + "\\s+(.*)", "");
				if (matcher.match(line)) {
					targetsInHxml.push({
						target: target,
						path: matcher.matched(1)
					});
				}
			}
		}
		return targetsInHxml;
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
