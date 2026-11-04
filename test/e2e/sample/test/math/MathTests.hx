package math;

import utest.Assert;

class MathTests extends utest.Test {
	function testAdds() {
		Assert.equals(4, 2 + 2);
	}

	function testCompares() {
		Assert.isTrue(3 > 2);
		Assert.isFalse(2 > 3);
	}
}
