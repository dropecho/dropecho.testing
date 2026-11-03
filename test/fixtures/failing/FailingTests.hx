class FailingTests extends utest.Test {
	function testFails() {
		utest.Assert.isTrue(false);
	}
}
