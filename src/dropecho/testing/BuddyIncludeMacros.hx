package dropecho.testing;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import dropecho.testing.Common;

using StringTools;
using haxe.macro.Tools;

class BuddyIncludeMacros {
	public static function BuildBuddyMain() {
		var suites = Common.collectSuites();

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
							var runner = new buddy.SuitesRunner(suites, new dropecho.testing.BuddyReporter());
							runner.run().then(_ -> {
								#if instrument
                // End instrumentation when manually running tests.
								instrument.coverage.Coverage.endCoverage();
								instrument.profiler.Profiler.endProfiler();
								#end

								dropecho.testing.ReportOutput.exit(runner.statusCode());
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
