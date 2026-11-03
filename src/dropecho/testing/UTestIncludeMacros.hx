package dropecho.testing;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import dropecho.testing.Common;

using StringTools;
using haxe.macro.Tools;

class UTestIncludeMacros {
	public static function BuiltUTestMain() {
		var suites = Common.collectSuites();

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
								// End instrumentation when manually running tests.
								instrument.coverage.Coverage.endCoverage();
								instrument.profiler.Profiler.endProfiler();
							});
							#end

							#if verbose
							utest.ui.Report.create(runner,
								utest.ui.common.HeaderDisplayMode.SuccessResultsDisplayMode.AlwaysShowSuccessResults,
								utest.ui.common.HeaderDisplayMode.AlwaysShowHeader);
							#elseif show_headers
							utest.ui.Report.create(runner,
								utest.ui.common.HeaderDisplayMode.SuccessResultsDisplayMode.NeverShowSuccessResults,
								utest.ui.common.HeaderDisplayMode.AlwaysShowHeader);
							#else
							utest.ui.Report.create(runner,
								utest.ui.common.HeaderDisplayMode.SuccessResultsDisplayMode.NeverShowSuccessResults,
								utest.ui.common.HeaderDisplayMode.NeverShowHeader);
							#end

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
