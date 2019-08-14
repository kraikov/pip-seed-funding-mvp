pragma solidity >=0.4.21 <0.6.0;

import "../external_contracts/SafeMath.sol";
import "../external_contracts/Ownable.sol";

import "./PipControllerInterface.sol";
import "./PipConfig.sol";
import "./Pip.sol";

contract PipController is PipControllerInterface, PipConfig, Ownable {

    using SafeMath for uint256;

    /**
    * @dev Total amount of funds provided by all patrons.
    * Increasing with every calling of `fund` function.
    */
    uint256 public totalPipInvestment;

    /**
    * @dev List of all PIP contracts that are deployed.
    */
    address[] public pipList;

    /**
    * @dev Keep track of all PIPs by their patron
    */
    mapping(address => address) public patronToPip;

    /**
    * @dev Creates a new PIP for given patron.
    * Updates the pipList along with patronToPip mapping.
    * This can use CREATE2 opcode in the future.
    */
    function createNewPip(address patron) public returns (address) {
        require(patronToPip[patron] == address(0), "PATRON_ALREADY_EXISTS");

        Pip pip = new Pip(
            TOKEN_RATIO,
            patron,
            PROJECT_WALLET,
            MONEY_MARKET,
            UNDERLYING_TOKEN,
            PROJECT_TOKEN
        );

        pipList.push(address(pip));

        patronToPip[patron] = address(pip);

        emit PipCreated(patron, address(pip));

        return address(pip);
    }

    /**
    * @dev When called, the msg.sender is considered as a patron.
    * If there is a valid PIP for the patron's address, then a new funding is being made.
    */
    function fund(uint256 amount) public {
        address patron = msg.sender;

        address pipAddr = patronToPip[patron];

        require(pipAddr != address(0x0), "INVALID_PATRON");

        Pip pip = Pip(pipAddr);

        pip.fund(amount);

        totalPipInvestment = totalPipInvestment.add(amount);

        emit PipFunded(patron, amount);
    }

    /**
    * @dev When called, the msg.sender is considered as a patron.
    * If there is a valid PIP for the patron's address, then a refund for certain amount is made.
    * The refund can transfer only the funded amount, excluding the accrued interest.
    * The accrued interest is being transferred to the project's address.
    */
    function refund(uint256 amount) public {
        address patron = msg.sender;

        address pipAddr = patronToPip[patron];

        require(pipAddr != address(0x0), "INVALID_PATRON");

        Pip pip = Pip(pipAddr);

        totalPipInvestment = totalPipInvestment.sub(amount);

        uint256 accruedInterest = pip.refund(amount);

        emit PatronRefunded(patron, amount, accruedInterest);
    }

    /**
    * @dev When called, the msg.sender is considered as a patron.
    * If there is a valid PIP for the patron's address,
    * then tokens are being minted for the patron.
    * The amount of tokens is dependent on the token ratio and the accrued interest.
    */
    function withdrawTokens(uint256 amount) public {
        address patron = msg.sender;

        address pipAddr = patronToPip[patron];

        require(pipAddr != address(0x0), "INVALID_PATRON");

        Pip pip = Pip(pipAddr);

        uint256 accruedInterest = pip.withdrawTokens(amount);

        emit TokensWithdrawn(patron, amount, accruedInterest);
    }

    /**
    * @dev Withdraws the accrued interest for given patron.
    * Can only be called by the project being funded.
    * Equivalent amount of tokens are transferred to the patron.
    */
    function withdrawAccruedInterest(uint256 amount, address patron) public onlyOwner {
        address pipAddr = patronToPip[patron];

        require(pipAddr != address(0x0), "INVALID_PATRON");

        Pip pip = Pip(pipAddr);

        uint256 tokenAmount = pip.withdrawAccruedInterest(amount);

        emit InterestWithdrawn(patron, amount, tokenAmount);
    }

    /**
    * @dev Withdraws the accrued interest for given range of patrons using the pip list..
    * Can only be called by the project being funded.
    * Equivalent amount of tokens are transferred to the patrons.
    */
    function withdrawAccruedInterest(uint256 from, uint256 to) public onlyOwner {
        uint256 pipCount = getPipCount();

        require(to < pipCount, "ARRAY_INDEX_OUT_OF_BOUND");

        for(uint256 index = from; index < to; index++) {
            Pip pip = Pip(pipList[index]);
            pip.withdrawAccruedInterest();
        }
    }

    /**
    * @dev Calculates the accrued interest for given patron.
    */
    function getAccruedInterest(address patron) public view returns (uint256 accruedInterest) {
        Pip pip = Pip(patronToPip[patron]);
        accruedInterest = pip.getAccruedInterest();
    }

    /**
    * @dev Calculates the accrued interest for all patrons combined.
    */
    function getAccruedInterest() public view returns (uint256 accruedInterest) {
        uint256 pipCount = getPipCount();

        for(uint256 index = 0; index < pipCount; index++) {
            Pip pip = Pip(pipList[index]);
            accruedInterest = accruedInterest.add(pip.getAccruedInterest());
        }
    }

    /**
    * @dev Calculates the amount of tokens for given patron with the latest accrued interest.
    */
    function getTokenAmount(address patron) public view returns (uint256 tokenAmount) {
        Pip pip = Pip(patronToPip[patron]);
        tokenAmount = pip.getTokenAmount();
    }

    /**
    * @dev Calculates the amount of tokens for given patron and accrued interest.
    */
    function getTokenAmount(address patron, uint256 accruedInterest) public view returns (uint256 tokenAmount) {
        Pip pip = Pip(patronToPip[patron]);
        tokenAmount = pip.getTokenAmount(accruedInterest);
    }

    /**
    * @dev Total amount of deployed PIPs
    */
    function getPipCount() public view returns (uint pipCount) {
        pipCount = pipList.length;
    }
}