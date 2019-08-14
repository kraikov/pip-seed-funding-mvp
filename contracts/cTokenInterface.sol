pragma solidity >=0.4.21 <0.6.0;

contract cTokenInterface {
    address public underlying;
    function mint(uint mintAmount) external returns (uint256);
    function redeemUnderlying(uint redeemAmount) external returns (uint256);
    function balanceOfUnderlying(address owner) external returns (uint256);
    function getCash() external view returns (uint256);
    function supplyRatePerBlock() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function exchangeRateStored() public view returns (uint256);
}
