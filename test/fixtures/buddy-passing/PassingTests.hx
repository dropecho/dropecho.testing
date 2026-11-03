using buddy.Should;

class PassingTests extends buddy.BuddySuite {
	public function new() {
		describe("Passing", {
			it("passes", {
				true.should.be(true);
			});
		});
	}
}
