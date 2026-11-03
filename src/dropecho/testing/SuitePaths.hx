package dropecho.testing;

import haxe.io.Path;

using StringTools;

/** The package and class name a suite file compiles to. **/
typedef SuiteTypePath = {
	pack:Array<String>,
	name:String,
}

/**
Path rules for test discovery. They live outside the macro code so they can be
unit tested at runtime. Every path is compared in `/` form, so Windows `\` paths
follow the same rules.
**/
class SuitePaths {
	static inline var SUITE_SUFFIX = "Tests.hx";

	/**
	Says whether discovery scans a classpath entry. Empty, commented and absolute
	entries (the std library and installed libraries) are skipped.

	@param classPath A classpath entry as the compiler reports it.
	@return True if the entry is a relative project folder.
	**/
	public static function isScanned(classPath:String):Bool {
		var path = classPath.trim();
		return path.length > 0 && !path.startsWith("#") && !Path.isAbsolute(path);
	}

	/**
	Says whether discovery walks into a folder. Hidden folders such as `.git` are
	never walked, since a Haxe package name cannot start with a dot.

	@param name The folder's own name.
	@return True if the folder may contain suites.
	**/
	public static function isWalked(name:String):Bool {
		return !name.startsWith(".");
	}

	/**
	Says whether a file is a test suite.

	@param name The file's own name.
	@return True if the name ends in `Tests.hx` and has something before it.
	**/
	public static function isSuiteFile(name:String):Bool {
		return name.length > SUITE_SUFFIX.length && name.endsWith(SUITE_SUFFIX);
	}

	/**
	Works out the type a suite file compiles to, from its path under a classpath root.

	@param root The classpath root the file was found under.
	@param file The suite file's path, starting with `root`.
	@return The suite's package and class name, or null if `file` is not under `root`.
	**/
	public static function typePath(root:String, file:String):Null<SuiteTypePath> {
		if (!file.startsWith(root)) {
			return null;
		}

		var parts = normalize(Path.withoutExtension(file.substring(root.length))).split("/");
		var name = parts.pop();
		return {pack: parts, name: name};
	}

	static function normalize(path:String):String {
		return Path.normalize(path.trim());
	}
}
