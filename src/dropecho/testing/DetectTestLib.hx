package dropecho.testing;

#if macro
import haxe.macro.Context;

using StringTools;
using haxe.macro.Tools;

enum DetectedTestLib {
	None;
	Buddy;
	UTest;
//   MUnit;
}

class DetectTestLib {
	public static function detectTestLib():DetectedTestLib {
		if (TryBuddy()) {
			return Buddy;
		}
		if (TryUTest()) {
			return UTest;
		}
		return None;
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
