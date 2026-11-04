package dropecho.testing;

import sys.io.Process;

/** What a compiled fixture printed, and the exit code it ended with. **/
typedef FixtureRun = {
	/** Everything printed, including compiler errors and warnings. **/
	output:String,
	/** Only what the fixture program printed; compiler warnings go to stderr. **/
	stdout:String,
	exitCode:Int,
}

/** Builds and runs the sample projects in `test/fixtures` with `AutoTest` as main. **/
class Fixture {
	/**
	Compiles and runs one fixture on the eval interpreter.

	@param name The folder name under `test/fixtures`.
	@param defines The `-D` flags to build it with.
	@param libraries The `--library` flags to build it with; defaults to utest.
	@return The fixture's output (combined and stdout only) and its exit code.
	**/
	public static function run(name:String, ?defines:Array<String>, ?libraries:Array<String>):FixtureRun {
		var lines = ["--class-path src", '--class-path test/fixtures/$name'];
		for (library in (libraries != null ? libraries : ["utest"])) {
			lines.push('--library $library');
		}
		for (define in (defines != null ? defines : [])) {
			lines.push('--define $define');
		}
		lines = lines.concat(["--main dropecho.testing.AutoTest", "--interp"]);

		var process = startHaxe(writeHxml(lines));
		var stdout = process.stdout.readAll().toString();
		var output = stdout + process.stderr.readAll().toString();
		var exitCode = process.exitCode();
		process.close();

		return {output: output, stdout: stdout, exitCode: exitCode};
	}

	/**
	Writes the build arguments to an hxml file, one option per line.

	Passing them in a file keeps values such as regex patterns (`a|b`) away from the
	Windows shell, which `haxe.cmd` would otherwise make parse them twice.

	@param lines The hxml lines.
	@return The path of the written file.
	**/
	static function writeHxml(lines:Array<String>):String {
		var dir = "artifacts/fixtures";
		sys.FileSystem.createDirectory(dir);
		var path = '$dir/build.hxml';
		sys.io.File.saveContent(path, lines.join("\n") + "\n");
		return path;
	}

	/**
	Starts `haxe` on an hxml file.

	On Windows, lix installs `haxe` as a `haxe.cmd` script, which `Process` can't start
	directly, so it goes through the shell.

	@param hxml The hxml file to build.
	@return The running compiler.
	**/
	static function startHaxe(hxml:String):Process {
		if (Sys.systemName() != "Windows") {
			return new Process("haxe", [hxml]);
		}
		return new Process("haxe " + StringTools.quoteWinArg(hxml, true));
	}
}
