package dropecho.testing;

#if (utest && !macro)
import utest.Runner;
import utest.ui.common.HeaderDisplayMode;
import utest.ui.text.PlainTextReport;

/**
Prints UTest results for `AutoTest`.

- Default: failures, then a one-line summary.
- `-D show_headers`: the full summary block, then failures.
- `-D verbose`: the full summary block, then every test.
**/
class UTestReport extends PlainTextReport {
	/**
	Attaches the report to a runner, so it prints when the run completes.

	@param runner The runner whose results to print.
	**/
	public function new(runner:Runner) {
		super(runner);
		setHandler(printResults);
		newline = "\n";
		indent = "  ";

		#if verbose
		displaySuccessResults = AlwaysShowSuccessResults;
		displayHeader = AlwaysShowHeader;
		#elseif show_headers
		displaySuccessResults = NeverShowSuccessResults;
		displayHeader = AlwaysShowHeader;
		#else
		displaySuccessResults = NeverShowSuccessResults;
		displayHeader = NeverShowHeader;
		#end
	}

	function printResults(report:PlainTextReport) {
		var lines = [StringTools.trim(getResults())];
		#if !(verbose || show_headers)
		lines.push(summaryLine());
		#end
		ReportOutput.print(lines.filter(line -> line.length > 0).join(newline));
	}

	function summaryLine():String {
		var stats = result.stats;
		var counts = 'assertions: ${stats.assertations}, successes: ${stats.successes}, failures: ${stats.failures}, errors: ${stats.errors}';
		return ReportOutput.resultLine(stats.isOk, counts);
	}
}
#end
