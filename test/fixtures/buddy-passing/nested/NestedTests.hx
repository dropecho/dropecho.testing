package nested;

using buddy.Should;

class NestedTests extends buddy.BuddySuite {
	public function new() {
		describe("Nested", {
			it("passes too", {
				true.should.be(true);
			});
		});
	}
}
