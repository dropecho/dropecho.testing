using buddy.Should;

class MathTests extends buddy.BuddySuite {
	public function new() {
		describe("Math", {
			it("adds", {
				(2 + 2).should.be(4);
			});
			it("subtracts", {
				(2 - 2).should.be(0);
			});
		});
	}
}
