package dropecho.testing;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem as FS;

using StringTools;
using haxe.macro.Tools;

typedef SuitesData = {
	suites:Array<String>,
}

class Common {
	public static function extractPath():Array<String> {
		var paths = [];
		var clsPath = Context.getClassPath();
		for (c in clsPath) {
			var t = c.trim();
			if (t.length > 0 && t.charAt(0) != "#" && t.charAt(0) != "/")
				paths.push(t);
		}

		return paths;
	}

	public static function extractExpr(base:String, path:String):Expr {
		if (path.startsWith(base)) {
			path = path.substring(base.length, path.length - 3);
			path = ~/\//g.replace(path, ".");

			var parts = path.split('.');
			var typePath = {
				name: parts.pop(),
				pack: parts,
			}
			return macro new $typePath();
		}

		Context.error("Invalid test suite: $path", Context.currentPos());
		return macro null;
	}

	public static function extractTestSuites(root:String, dir:String, data:SuitesData):SuitesData {
		if (FS.isDirectory(dir)) {
			var entries = FS.readDirectory(dir);

			for (entry in entries) {
				var path = dir + entry;

				if (FS.isDirectory(path)) {
					extractTestSuites(root, path + "/", data);
				} else {
					if (entry.length > 8 && entry.endsWith("Tests.hx")) {
						data.suites.push(path);
					}
				}
			}
		}

		return data;
	}
}
#end
