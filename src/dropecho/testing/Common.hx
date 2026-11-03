package dropecho.testing;

#if macro
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem as FS;

using StringTools;
using haxe.macro.Tools;

typedef SuitesData = {
	suites:Array<String>,
}

class Common {
	/**
	Finds every test suite on the project's classpaths.

	@return One `new Suite()` expression per discovered `*Tests.hx` file.
	**/
	public static function collectSuites():Array<Expr> {
		var suites = [];

		for (root in extractPath()) {
			var found = extractTestSuites(root, root, {suites: []});
			for (file in found.suites) {
				suites.push(extractExpr(root, file));
			}
		}

		return suites;
	}

	/**
	Lists the classpaths discovery scans: the relative ones, which belong to the project.

	@return The classpath entries, trimmed.
	**/
	public static function extractPath():Array<String> {
		var paths = [];
		for (classPath in Context.getClassPath()) {
			if (SuitePaths.isScanned(classPath)) {
				paths.push(classPath.trim());
			}
		}

		return paths;
	}

	/**
	Builds the `new` expression for one suite file.

	@param base The classpath root the file was found under.
	@param path The suite file's path, starting with `base`.
	@return An expression constructing the suite.
	**/
	public static function extractExpr(base:String, path:String):Expr {
		var suite = SuitePaths.typePath(base, path);
		if (suite == null) {
			Context.error('Invalid test suite: $path', Context.currentPos());
			return macro null;
		}

		var typePath:TypePath = {pack: suite.pack, name: suite.name};
		return macro new $typePath();
	}

	/**
	Walks a folder and collects the paths of its suite files.

	@param root The classpath root the walk started from.
	@param dir The folder to walk, under `root`.
	@param data Collects the suite paths found.
	@return `data`, with the suites under `dir` added.
	**/
	public static function extractTestSuites(root:String, dir:String, data:SuitesData):SuitesData {
		if (!FS.isDirectory(dir)) {
			return data;
		}

		var folder = Path.addTrailingSlash(dir);
		for (entry in FS.readDirectory(folder)) {
			var path = folder + entry;

			if (FS.isDirectory(path)) {
				if (SuitePaths.isWalked(entry)) {
					extractTestSuites(root, path, data);
				}
			} else if (SuitePaths.isSuiteFile(entry)) {
				data.suites.push(path);
			}
		}

		return data;
	}
}
#end
