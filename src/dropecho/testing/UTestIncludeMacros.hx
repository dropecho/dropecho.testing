package dropecho.testing;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import dropecho.testing.Common;

using StringTools;
using haxe.macro.Tools;

class UTestIncludeMacros {
	static var dotReg = ~/(\.)/g;
	static var hxExt = ~/(\.hx$)/;

	public static function BuiltUTestMain() {
		var paths = Common.extractPath();

		if (paths == null) {
			Context.error("Could not find the sources directory", Context.currentPos());
		}

		var suites = [];
		for (path in paths) {
			var suitesData = Common.extractTestSuites(path, path, {
				suites: [],
			});

			for (s in suitesData.suites) {
				suites.push(Common.extractExpr(path, s));
			}
		}

		Context.defineType({
			name: "TestSuites",
			pack: "dropecho.testing".split('.'),
			params: [],
			fields: [
				{
					name: "main",
					kind: FFun({
						args: [],
						params: null,
						ret: null,
						expr: macro {
							var runner = new utest.Runner();

							for (s in $a{suites}) {
								runner.addCase(s);
							}

							#if instrument
							runner.onComplete.add(_ -> {
								instrument.coverage.Coverage.endCoverage();
							});
							#end

							utest.ui.Report.create(runner, utest.ui.common.HeaderDisplayMode.SuccessResultsDisplayMode.NeverShowSuccessResults,
								utest.ui.common.HeaderDisplayMode.NeverShowHeader);

							runner.run();
						}
					}),
					access: [APublic, AStatic],
					doc: null,
					meta: null,
					pos: Context.currentPos()
				}
			],
			meta: null,
			isExtern: null,
			kind: TDClass(null, null, false, false, false),
			pos: Context.currentPos()
		});
	}
}
#end
