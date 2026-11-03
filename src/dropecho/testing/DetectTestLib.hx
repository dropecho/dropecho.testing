package dropecho.testing;

#if macro
import haxe.macro.Context;

using StringTools;
using haxe.macro.Tools;

enum DetectedTestLib {
	None;
	Buddy;
	UTest;
}

class DetectTestLib {
	/**
	Picks the test library to generate a runner for.

	`-D dropecho_testing_lib=utest|buddy` chooses one; otherwise Buddy wins
	when both are on the classpath.

	@return The library to use, or `None` when neither is on the classpath.
	**/
	public static function detectTestLib():DetectedTestLib {
		var requested = Context.definedValue("dropecho_testing_lib");
		if (requested == null || requested.trim() == "") {
			return detectAvailable();
		}

		return switch (requested.trim().toLowerCase()) {
			case "buddy":
				requireAvailable(TryBuddy(), "buddy", Buddy);
			case "utest":
				requireAvailable(TryUTest(), "utest", UTest);
			case unknown:
				Context.fatalError('Unknown dropecho_testing_lib "$unknown". Valid values: buddy, utest.', Context.currentPos());
		}
	}

	static function detectAvailable():DetectedTestLib {
		if (TryBuddy()) {
			return Buddy;
		}
		if (TryUTest()) {
			return UTest;
		}
		return None;
	}

	/**
	Fails the build when the chosen library is not on the classpath.

	@param available Whether the library was found.
	@param name The library's haxelib name, for the error message.
	@param lib The library to return when it was found.
	@return `lib`.
	**/
	static function requireAvailable(available:Bool, name:String, lib:DetectedTestLib):DetectedTestLib {
		if (!available) {
			Context.fatalError('dropecho_testing_lib is "$name", but $name is not on the classpath. Add --library $name.', Context.currentPos());
		}
		return lib;
	}

	public static function TryUTest() {
		try {
			Context.getType("utest.Runner");
			return true;
		} catch (err) {
			return false;
		}
	}

	public static function TryBuddy() {
		try {
			Context.getType("buddy.Buddy");
			return true;
		} catch (err) {
			return false;
		}
	}
}
#end
