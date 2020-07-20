const Prescription = artifacts.require("./Prescription.sol");

contract("Prescription", accounts => {
  it("should store the string 'Hey there!'", async () => {
    const Prescription = await Prescription.deployed();

    // Set myString to "Hey there!"
    await Prescription.set("Hey there!", { from: accounts[0] });

    // Get myString from public variable getter
    const storedString = await Prescription.myString.call();

    assert.equal(storedString, "Hey there!", "The string was not stored");
  });
});