using buddy.Should;

// Always fails, so a passing filtered run shows this suite was left out.
class BrokenTests extends buddy.BuddySuite {
	public function new() {
		describe("Broken", {
			it("fails", {
				true.should.be(false);
			});
		});
	}
}
