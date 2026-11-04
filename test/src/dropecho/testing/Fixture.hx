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
		var args = ["--class-path", "src", "--class-path", 'test/fixtures/$name'];
		for (library in (libraries != null ? libraries : ["utest"])) {
			args = args.concat(["--library", library]);
		}
		for (define in (defines != null ? defines : [])) {
			args = args.concat(["-D", define]);
		}
		args = args.concat(["--main", "dropecho.testing.AutoTest", "--interp"]);

		var process = startHaxe(args);
		var stdout = process.stdout.readAll().toString();
		var output = stdout + process.stderr.readAll().toString();
		var exitCode = process.exitCode();
		process.close();

		return {output: output, stdout: stdout, exitCode: exitCode};
	}

	/**
	Starts `haxe` with the given arguments.

	On Windows, lix installs `haxe` as a `haxe.cmd` script, which `Process` can't start
	directly, so it goes through the shell with each argument quoted.

	@param args The compiler arguments.
	@return The running compiler.
	**/
	static function startHaxe(args:Array<String>):Process {
		if (Sys.systemName() != "Windows") {
			return new Process("haxe", args);
		}
		var line = ["haxe"].concat([for (arg in args) StringTools.quoteWinArg(arg, true)]).join(" ");
		return new Process(line);
	}
}
