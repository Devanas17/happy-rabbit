const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HappyRabbit", function () {
  // Define the test variables
  let happyRabbitContract;
  let owner;
  let addr1;
  let addr2;
  let rabbitUri = "https://example.com/rabbit.json";

  beforeEach(async () => {
    // Deploy the contract and get the accounts
    const HappyRabbit = await ethers.getContractFactory("HappyRabbit");
    [owner, addr1, addr2] = await ethers.getSigners();
    happyRabbitContract = await HappyRabbit.deploy();
  });

  describe("Depolying", () => {
    it("Should set the name and symbol", async () => {
      const name = await happyRabbitContract.name();
      const symbol = await happyRabbitContract.symbol();

      expect(name).to.equal("HappyRabbit");
      expect(symbol).to.equal("HRB");
    });
  });

  describe("minting", () => {
    it("should mint a new token with the correct URI", async () => {
      // Mint a new token with a given URI
      await happyRabbitContract.safeMint(addr1.address, rabbitUri);

      // Check the token URI and owner
      const tokenURI = await happyRabbitContract.tokenURI(0);
      expect(tokenURI).to.equal(rabbitUri);
      expect(await happyRabbitContract.ownerOf(0)).to.equal(addr1.address);
    });

    it("should increment the token ID counter", async () => {
      // Mint two new tokens
      await happyRabbitContract.safeMint(addr1.address, rabbitUri);
      await happyRabbitContract.safeMint(addr1.address, rabbitUri);

      // Check that the token ID counter has been incremented
      const tokenURI = await happyRabbitContract.tokenURI(1);
      expect(tokenURI).to.equal(rabbitUri);
      expect(await happyRabbitContract.ownerOf(1)).to.equal(addr1.address);
    });

    it("should only allow the owner to mint a new token", async () => {
      // Mint a new token from a non-owner account
      await expect(
        happyRabbitContract.connect(addr1).safeMint(addr2.address, rabbitUri)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });
  });
});
