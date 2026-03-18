import { expect } from "chai";
import {network} from "hardhat"

const {ethers} = await network.connect()

describe("StakeToken", () => {
  let stakeToken: any;
  let owner: any;
  let addr1: any;

  beforeEach(async () => {
    [owner, addr1] = await ethers.getSigners();

    const StakeToken = await ethers.getContractFactory("StakeToken");
    stakeToken = await StakeToken.deploy();
    await stakeToken.waitForDeployment();
  });

  it("deploys with correct token details and supply", async () => {
    expect(await stakeToken.name()).to.equal("Stake Token");
    expect(await stakeToken.symbol()).to.equal("STK");

    const expectedSupply = ethers.parseUnits("1000000", 18);

    expect(await stakeToken.totalSupply()).to.equal(expectedSupply);
    expect(await stakeToken.balanceOf(owner.address)).to.equal(expectedSupply);
  });

  it("allows only owner to mint", async () => {
    const amount = ethers.parseUnits("1000", 18);

    await stakeToken.mint(addr1.address, amount);

    expect(await stakeToken.balanceOf(addr1.address)).to.equal(amount);

    await expect(
      stakeToken.connect(addr1).mint(addr1.address, amount)
    ).to.be.revertedWithCustomError(stakeToken, "OwnableUnauthorizedAccount");
  });


  it("allows token transfers", async () => {
    const amount = ethers.parseUnits("100", 18);
  
    await stakeToken.transfer(addr1.address, amount);
  
    expect(await stakeToken.balanceOf(addr1.address)).to.equal(amount);
  });

 
});