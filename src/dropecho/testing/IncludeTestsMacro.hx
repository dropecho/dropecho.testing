package dropecho.testing;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;
using haxe.macro.Tools;

class IncludeTestsMacro {
	// Will include all tests suites whose name ends with "Tests"
	public static function buildTests() {
		var fields = Context.getBuildFields();

		var testSuite = Context.definedValue("dropecho_testing_suite");
		if (testSuite != null && StringTools.trim(testSuite) != "") {
			return makeTestSuiteProxy(fields, testSuite);
		}

		var detected = DetectTestLib.detectTestLib();
		switch (detected) {
			case Buddy:
				dropecho.testing.BuddyIncludeMacros.BuildBuddyMain();
			case UTest:
				UTestIncludeMacros.BuiltUTestMain();
			default:
				var error = "No or unsupported test lib detected. Try including buddy, utest or munit.";
				Context.error(error, Context.currentPos());
		}

		fields.push({
			name: "main",
			kind: FFun({
				args: [],
				params: null,
				ret: null,
				expr: macro {
					TestSuites.main();
				}
			}),
			access: [APublic, AStatic],
			doc: null,
			meta: null,
			pos: Context.currentPos()
		});

		return fields;
	}

	static function makeTestSuiteProxy(fields:Array<Field>, suite:String):Array<Field> {
		return fields.concat((macro class {
			public static function main() {
				$p{suite.split(".")}.main();
			}
		}).fields);
	}
}
#end
