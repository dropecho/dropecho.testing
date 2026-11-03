using buddy.Should;

class FailingTests extends buddy.BuddySuite {
	public function new() {
		describe("Failing", {
			it("fails", {
				true.should.be(false);
			});
			it("passes", {
				true.should.be(true);
			});
		});
	}
}
