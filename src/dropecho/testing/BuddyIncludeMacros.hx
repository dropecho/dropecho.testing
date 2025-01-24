package dropecho.testing;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import dropecho.testing.Common;

using StringTools;
using haxe.macro.Tools;

class BuddyIncludeMacros {
	static var dotReg = ~/(\.)/g;
	static var hxExt = ~/(\.hx$)/;

	public static function BuildBuddyMain() {
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
					pos: Context.currentPos(),
					name: "main",
					meta: [],
					kind: FFun({
						ret: null,
						params: [],
						expr: macro {
							var suites = $a{suites};
							var runner = new buddy.SuitesRunner(suites, null);
							runner.run().then(_ -> {
								#if instrument
								instrument.coverage.Coverage.endCoverage();
								#end

								Sys.exit(runner.statusCode());
							});
						},
						args: []
					}),
					doc: null,
					access: [Access.AStatic, Access.APublic],
				}
			],
			meta: null,
			isExtern: null,
			kind: TDClass(null, null, null, false, false),
			pos: Context.currentPos()
		});
	}
}
#end
