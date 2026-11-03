package dropecho.testing;

/** Output helpers shared by the UTest and Buddy reports. **/
class ReportOutput {
	/**
	Prints text on any target, without the `File.hx:line:` prefix `trace` adds.

	@param text The text to print.
	**/
	public static function print(text:String) {
		haxe.Log.trace(text, null);
	}

	/**
	Builds the one-line summary printed in the default output mode.

	@param ok Whether every test passed.
	@param counts The counts to show in brackets, such as `specs: 2, failures: 0`.
	@return The summary line.
	**/
	public static function resultLine(ok:Bool, counts:String):String {
		var result = ok ? "ALL TESTS OK" : "SOME TESTS FAILURES";
		return 'results: $result ($counts)';
	}
}
