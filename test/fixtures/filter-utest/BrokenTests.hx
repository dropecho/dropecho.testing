// Always fails, so a passing filtered run shows this suite was left out.
class BrokenTests extends utest.Test {
	function testFails() {
		utest.Assert.isTrue(false);
	}
}
