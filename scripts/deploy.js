const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
  const HappyRabbit = await hre.ethers.getContractFactory("HappyRabbit");
  const happyRabbit = await HappyRabbit.deploy();
  const [addr1, addr2] = await ethers.getSigners();
  await happyRabbit.deployed();

  const mint = await happyRabbit.safeMint(addr1.address);
  await mint.wait();

  console.log(` deployed to ${happyRabbit.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
