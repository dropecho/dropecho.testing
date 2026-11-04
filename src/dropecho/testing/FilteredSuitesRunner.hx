package dropecho.testing;

#if (buddy && !macro)
import buddy.BuddySuite;
import buddy.BuddySuite.TestSuite;
import buddy.SuitesRunner;
import buddy.reporting.Reporter;

using Lambda;

/**
Runs only the Buddy specs whose full name matches a pattern.

A spec's full name is its class path, a dot, then its `describe` and `it`
descriptions joined by spaces, such as `math.MathTests.Math adds two numbers`.
The pattern is a regular expression searched anywhere in that name.
**/
class FilteredSuitesRunner extends SuitesRunner {
	final pattern:String;
	final matcher:EReg;
	final usesIncludeMeta:Bool;

	/**
	Creates a runner that keeps only matching specs.

	@param buddySuites The suites to run.
	@param reporter The reporter that prints the results.
	@param pattern The regular expression a spec's full name must match.
	**/
	public function new(buddySuites:Iterable<BuddySuite>, reporter:Reporter, pattern:String) {
		super(buddySuites, reporter);
		this.pattern = pattern;
		matcher = new EReg(pattern, "");
		// Buddy only builds the spec tree once the run starts, then calls startIncludeMode
		// when this is set, which is where the specs can be filtered.
		usesIncludeMeta = includeMode;
		includeMode = true;
	}

	override function startIncludeMode() {
		if (usesIncludeMeta) {
			super.startIncludeMode();
		}

		buddySuites = buddySuites.filter(buddySuite -> keepMatching(Type.getClassName(Type.getClass(buddySuite)), buddySuite.suite, []));

		if (buddySuites.empty()) {
			ReportOutput.noMatches(pattern);
		}
	}

	/**
	Removes the specs in a suite whose full name does not match.

	@param className The class path of the test class the suite belongs to.
	@param suite The suite to filter.
	@param descriptions The `describe` descriptions above this suite.
	@return Whether any spec is left in the suite.
	**/
	function keepMatching(className:String, suite:TestSuite, descriptions:Array<String>):Bool {
		suite.specs = suite.specs.filter(spec -> switch (spec) {
			case Describe(child, _):
				keepMatching(className, child, descriptions.concat([child.description]));
			case It(description, _, _, _):
				matcher.match(className + "." + descriptions.concat([description]).join(" "));
		});
		return !suite.specs.isEmpty();
	}
}
#end
