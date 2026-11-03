// Lives in a hidden folder, which is not a valid package, so discovery must never include it.
class HiddenTests extends utest.Test {
	function testHidden() {
		utest.Assert.fail("hidden folders must not be discovered");
	}
}
