pragma solidity >=0.4.21 <0.6.0;

import "../external_contracts/SafeERC20.sol";
import "./cTokenInterface.sol";


contract PipInterface {
    uint256 public totalInvestment;
    uint256 public tokenRatio;

    address public patron;
    address public fundedProject;

    cTokenInterface public moneyMarket;

    IERC20 public underlyingToken;
    IERC20 public projectToken;

    function fund(uint256 amount) public;
    function refund(uint256 amount) public returns (uint256 accruedInterest);

    function withdrawTokens() public returns (uint256 accruedInterest);
    function withdrawTokens(uint256 amount) public returns (uint256 accruedInterest);

    function withdrawAccruedInterest() public returns (uint256 tokenAmount);
    function withdrawAccruedInterest(uint256 amount) public returns (uint256 tokenAmount);

    function getTokenAmount() public view returns (uint256 amount);
    function getTokenAmount(uint256 accruedInterest) public view returns (uint256 tokenAmount);

    function getAccruedInterest() public view returns (uint256 accruedInterest);
}