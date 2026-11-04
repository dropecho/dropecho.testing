package dropecho.testing;

#if macro
import haxe.macro.Context;

/** Reads `-D dropecho_testing_filter`, which limits a run to tests whose full name matches. **/
class TestFilter {
	static inline var DEFINE = "dropecho_testing_filter";

	/**
	Reads and checks the filter pattern.

	Stops the build when the define is set but empty. The pattern itself is not checked
	here: the macro interpreter reports a bad regular expression as an error that can't
	be caught, so it is left to the regex engine of the target that runs the tests.

	@return The pattern, or `null` when the define is not set.
	**/
	public static function fromDefine():Null<String> {
		var pattern = Context.definedValue(DEFINE);
		if (pattern == null) {
			return null;
		}

		if (pattern.length == 0) {
			Context.error('$DEFINE needs a pattern, such as -D $DEFINE=MathTests.', Context.currentPos());
		}

		return pattern;
	}
}
#end
