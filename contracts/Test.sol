// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;



interface IERC20 {
    function transfer(address to,uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner,address spender) external view returns (uint256);
    function approve(address spender,uint256 amount) external returns (bool);
}


contract Test {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;


    //state variables
    IERC20 public token;

    constructor(uint256 initialSupply) {
        balances[msg.sender] = initialSupply;
    }


    function transfer(address _to,uint256 _amount) public returns(bool) {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        return true;
    }

    function transferFrom(address _from,address _to,uint256 _amount) public returns(bool) {
        require(balances[_from] >= _amount, "Insufficient balance");
        require(allowances[_from][msg.sender] >= _amount, "Insufficient allowance");
        balances[_from] -= _amount;
        balances[_to] -= _amount;
        allowances[_from][msg.sender] -= _amount;
        return true;
    }
}