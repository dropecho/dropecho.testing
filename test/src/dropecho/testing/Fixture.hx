package dropecho.testing;

import sys.io.Process;

/** What a compiled fixture printed, and the exit code it ended with. **/
typedef FixtureRun = {
	output:String,
	exitCode:Int,
}

/** Builds and runs the sample projects in `test/fixtures` with `AutoTest` as main. **/
class Fixture {
	/**
	Compiles and runs one fixture on the eval interpreter.

	@param name The folder name under `test/fixtures`.
	@param defines The `-D` flags to build it with.
	@param libraries The `--library` flags to build it with; defaults to utest.
	@return The fixture's combined output and its exit code.
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

		var process = new Process("haxe", args);
		var output = process.stdout.readAll().toString() + process.stderr.readAll().toString();
		var exitCode = process.exitCode();
		process.close();

		return {output: output, exitCode: exitCode};
	}
}
