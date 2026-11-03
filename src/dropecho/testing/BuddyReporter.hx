package dropecho.testing;

#if (buddy && !macro)
import buddy.BuddySuite.Spec;
import buddy.BuddySuite.Suite;
import buddy.reporting.Reporter;
import haxe.CallStack.StackItem;
import promhx.Deferred;
import promhx.Promise;

using StringTools;

/** Spec totals across a whole run. **/
typedef SpecCounts = {
	total:Int,
	failures:Int,
	pending:Int,
}

/**
Prints Buddy results for `AutoTest`, matching the UTest output modes.

- Default: failed specs, then a one-line summary.
- `-D show_headers`: a summary block, then failed specs.
- `-D verbose`: a summary block, then every spec.
**/
class BuddyReporter implements Reporter {
	public function new() {}

	/**
	Called before the run starts.

	@return A promise resolved with `true`, so the run goes ahead.
	**/
	public function start():Promise<Bool> {
		return resolved(true);
	}

	/**
	Called after each spec. Prints nothing, to keep the output quiet.

	@param spec The spec that just finished.
	@return A promise resolved with the same spec.
	**/
	public function progress(spec:Spec):Promise<Spec> {
		return resolved(spec);
	}

	/**
	Called after the last spec; prints the results.

	@param suites Every suite that ran.
	@param status Whether every spec passed.
	@return A promise resolved with the same suites.
	**/
	public function done(suites:Iterable<Suite>, status:Bool):Promise<Iterable<Suite>> {
		var counts = {total: 0, failures: 0, pending: 0};
		var specLines = [];
		for (suite in suites) {
			count(suite, counts);
			specLines = specLines.concat(suiteLines(suite, -1));
		}

		#if (verbose || show_headers)
		var lines = header(counts, status).concat(specLines);
		#else
		var counted = 'specs: ${counts.total}, failures: ${counts.failures}, pending: ${counts.pending}';
		var lines = specLines.concat([ReportOutput.resultLine(status, counted)]);
		#end

		ReportOutput.print(lines.join("\n"));
		return resolved(suites);
	}

	function header(counts:SpecCounts, status:Bool):Array<String> {
		return [
			'specs: ${counts.total}',
			'failures: ${counts.failures}',
			'pending: ${counts.pending}',
			"",
			"results: " + (status ? "ALL TESTS OK (success: true)" : "SOME TESTS FAILURES (success: false)"),
		];
	}

	function count(suite:Suite, counts:SpecCounts) {
		// A suite that crashed counts as a failure, as in Buddy's own reporters.
		if (suite.error != null) {
			counts.failures++;
		}
		for (spec in suite.specs) {
			counts.total++;
			switch (spec.status) {
				case Failed:
					counts.failures++;
				case Pending:
					counts.pending++;
				case _:
			}
		}
		for (child in suite.suites) {
			count(child, counts);
		}
	}

	/**
	Lists a suite's shown specs under its description, indented by depth.

	@param suite The suite to list.
	@param depth How deep the suite is; a test class's root suite is -1.
	@return The lines to print, or none when no spec in it is shown.
	**/
	function suiteLines(suite:Suite, depth:Int):Array<String> {
		var indent = "".lpad(" ", depth * 2);
		var title = suite.description.length > 0 ? [indent + suite.description] : [];

		if (suite.error != null) {
			return title.concat(['$indent  ERROR: ${suite.error}']).concat(stackLines(suite.stack, '$indent  '));
		}

		var body = [];
		for (step in suite.steps) {
			switch (step) {
				case TSpec(spec) if (isShown(spec)):
					body = body.concat(specLines(spec, '$indent  '));
				case TSpec(_):
				case TSuite(child):
					body = body.concat(suiteLines(child, depth + 1));
			}
		}

		return body.length > 0 ? title.concat(body) : [];
	}

	function isShown(spec:Spec):Bool {
		#if verbose
		return true;
		#else
		return spec.status == Failed;
		#end
	}

	function specLines(spec:Spec, indent:String):Array<String> {
		var label = spec.status == Failed ? "FAILED" : Std.string(spec.status);
		var lines = ['$indent${spec.description} ($label)'];
		for (traced in spec.traces) {
			lines.push('$indent  $traced');
		}
		for (failure in spec.failures) {
			lines.push('$indent  ${failure.error}');
			lines = lines.concat(stackLines(failure.stack, '$indent    '));
		}
		return lines;
	}

	// Keeps only the test's own frames, dropping Buddy's internals.
	function stackLines(stack:Array<StackItem>, indent:String):Array<String> {
		var lines = [];
		if (stack == null) {
			return lines;
		}
		for (item in stack) {
			switch (item) {
				case FilePos(_, file, line) if (line > 0 && !file.startsWith("buddy/internal/") && !file.startsWith("buddy.SuitesRunner")):
					lines.push('$indent@ $file:$line');
				case _:
			}
		}
		return lines;
	}

	function resolved<T>(value:T):Promise<T> {
		var deferred = new Deferred<T>();
		var promise = deferred.promise();
		deferred.resolve(value);
		return promise;
	}
}
#end
