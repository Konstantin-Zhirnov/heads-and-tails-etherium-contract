const hre = require("hardhat");

async function main() {

  const HeadsAndTails = await hre.ethers.getContractFactory("HeadsAndTails");
  const headsAndTails = await HeadsAndTails.deploy();

  await headsAndTails.deployed();

  console.log(`CoinGame deployed to: ${headsAndTails.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});