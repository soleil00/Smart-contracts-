// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

using SafeERC20 for IERC20;



contract Staking is Ownable, ReentrancyGuard { 
    IERC20 public token;
    uint256 public rewardRate = 1e16; //1e16 = 0.01 token per second i.e reward per sec when user stake soem tokens
    
    struct User {
        uint256 stakedAmount; //how much token user has staked
        uint256 totalRewards; //how much reward user has earned
        uint256 lastUpdate; //when user last claimed rewards
    }

    mapping(address => User) public users; //store data for each user

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 amount);


    constructor(address _token) Ownable(msg.sender) {
        token = IERC20(_token);
    }


    function setRewardRate(uint256 _rewardRate) public onlyOwner {
        rewardRate = _rewardRate;
    }

    function stake(uint256 _amount) public nonReentrant {
        _updateUserRewards(msg.sender);
        require(_amount > 0, "Amount must be greater than 0");
        users[msg.sender].stakedAmount += _amount;
        token.safeTransferFrom(msg.sender, address(this), _amount);
        emit Staked(msg.sender, _amount);
    }


    function unstake(uint256 _amount) public nonReentrant {
        require(_amount > 0, "Amount must be greater than 0");
        require(users[msg.sender].stakedAmount >= _amount, "Insufficient staked amount");
        _updateUserRewards(msg.sender);
        users[msg.sender].stakedAmount -= _amount;
        token.safeTransfer(msg.sender, _amount);
        emit Unstaked(msg.sender, _amount);

    }


    function claimReward() public nonReentrant{
        _updateUserRewards(msg.sender);
        uint256 rewards = users[msg.sender].totalRewards;
        require(rewards > 0, "No rewards to claim");
        users[msg.sender].totalRewards = 0;
        token.safeTransfer(msg.sender, rewards);
        emit Claimed(msg.sender, rewards);
    }


    function pendingRewards(address _user) public view returns (uint256) {
        User storage user = users[_user];
        uint256 timeElapsed = block.timestamp - user.lastUpdate;
        uint256 rewards = (timeElapsed *user.stakedAmount * rewardRate)/1e18;
        return rewards + user.totalRewards;
    }

    
    function _updateUserRewards(address _user) internal {
        User storage user = users[_user];
         if(user.lastUpdate == 0) {
            user.lastUpdate = block.timestamp;
            return;
        }

        uint256 timeElapsed = block.timestamp - user.lastUpdate;
        uint256 rewards = (timeElapsed * user.stakedAmount * rewardRate)/1e18;
        user.totalRewards += rewards;
        user.lastUpdate = block.timestamp;
    }

}


//lock period
//penalty
//APY instead of fixed rate