import { network } from "hardhat";

const { ethers } = await network.connect();

async function main() {

  const [deployer] = await ethers.getSigners();

  console.log("Deploying contract with account:", deployer.address);

  const StakeToken = await ethers.getContractFactory("StakeToken");

  const stakeToken = await StakeToken.deploy();

  await stakeToken.waitForDeployment();

  const address = await stakeToken.getAddress();

  console.log("StakeToken deployed to:", address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});