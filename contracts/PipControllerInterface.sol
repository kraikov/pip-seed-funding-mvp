pragma solidity >=0.4.21 <0.6.0;

contract PipControllerInterface {
    uint256 public totalPipInvestment;
    address[] public pipList;
    mapping(address => address) public patronToPip;

    function createNewPip(address patron) public returns (address);

    function fund(uint256 amount) public;
    function refund(uint256 amount) public;

    function withdrawTokens(uint256 amount) public;

    function withdrawAccruedInterest(uint256 amount, address patron) public;
    function withdrawAccruedInterest(uint256 from, uint256 to) public;

    function getAccruedInterest() public view returns (uint256 accruedInterest);
    function getAccruedInterest(address patron) public view returns (uint256 accruedInterest);

    function getTokenAmount(address patron) public view returns (uint256 tokenAmount);
    function getTokenAmount(address patron, uint256 accruedInterest) public view returns (uint256 tokenAmount);

    function getPipCount() public view returns (uint256);

    event PipCreated(address indexed patron, address indexed pip);
    event PipFunded(address indexed patron, uint256 amount);
    event PatronRefunded(address indexed patron, uint256 amount, uint256 accruedInterest);
    event TokensWithdrawn(address indexed patron, uint256 amount, uint256 accruedInterest);
    event InterestWithdrawn(address indexed patron, uint256 amount, uint256 tokenAmount);
}