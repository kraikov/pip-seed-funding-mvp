pragma solidity >=0.4.21 <0.6.0;

import "../external_contracts/SafeERC20.sol";
import "../external_contracts/SafeMath.sol";
import "../external_contracts/Ownable.sol";

import "./cTokenInterface.sol";
import "./PipInterface.sol";


contract Pip is PipInterface, Ownable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 constant internal PRECISION = 10 ** 18;

    /**
    * @dev Total amount of funds provided by the patron.
    * Increasing with every calling of `fund` function.
    */
    uint256 public totalInvestment;

    /**
    * @dev Ratio between accrued interest and the project's token.
    */
    uint256 public tokenRatio;

    /**
    * @dev PIP's patron.
    */
    address public patron;

    /**
    * @dev Project's address where the accrued interest will be transferred
    */
    address public fundedProject;

    /**
    * @dev The market being used for the Compound interractions.
    */
    cTokenInterface public moneyMarket;

    /**
    * @dev The underlying asset of the money market.
    */
    IERC20 public underlyingToken;

    /**
    * @dev The project's token that will be acculumated for the patron.
    */
    IERC20 public projectToken;

    constructor(
        uint256 _tokenRatio,
        address _patron,
        address _fundedProject,
        address _moneyMarket,
        address _underlyingToken,
        address _projectToken
        ) public
    {
        tokenRatio = _tokenRatio;
        patron = _patron;
        fundedProject = _fundedProject;
        moneyMarket = cTokenInterface(_moneyMarket);
        underlyingToken = IERC20(_underlyingToken);
        projectToken = IERC20(_projectToken);
    }

    /**
    * @dev Supplies the Compound Protocol with certain amount of
    * the current money market on the patron's behalf.
    */
    function fund(uint256 amount) public onlyOwner {
        underlyingToken.safeTransferFrom(patron, address(this), amount);

        totalInvestment = totalInvestment.add(amount);

        underlyingToken.safeApprove(address(moneyMarket), amount);

        require(moneyMarket.mint(amount) == 0, "SUPPLY_MONEY_MARKET_FAILED");
    }

    /**
    * @dev Refunds a specified amount from the Compound Protocol directly to
    * patron's address. Along with that transfers
    * the whole accrued interest in the project's address.
    */
    function refund(uint256 amount) public onlyOwner returns (uint256 accruedInterest) {
        uint256 maxRefundBalance = totalInvestment;

        require(maxRefundBalance >= amount, "REFUND_AMOUNT_EXCEEDED");

        // Reduce the patron's investment.
        totalInvestment = totalInvestment.sub(amount);

        // Accrued interest is equal to the actual balance minus the initial investment.
        accruedInterest = getAccruedInterestInternal();

        // Redeem the interest plus the refund amount in order to send the interest to the project.
        uint256 redeemedAmount = amount.add(accruedInterest);

        require(moneyMarket.redeemUnderlying(redeemedAmount) == 0, "REDEEM_FROM_COMPOUND_FAILED");

        // Make the patron's refund.
        underlyingToken.safeTransfer(address(patron), amount);

        // Send acrrued interest to the project's wallet.
        underlyingToken.safeTransfer(address(fundedProject), accruedInterest);
    }

    /**
    * @dev Withdraw the whole amount of tokens to the patron's address according to the accrued interest.
    * On that point, the tokens are actually being created (minted) using the formula:
    * TOKEN_AMOUNT = ACCRUED_INTEREST * TOKEN_RATIO
    * Along with that interest with the value equal to the value of tokens being withdrawn are
    * transferred to the project's address.
    */
    function withdrawTokens() public onlyOwner returns (uint256 accruedInterest) {
        accruedInterest = getAccruedInterestInternal();

        uint256 tokenAmount = getTokenAmount(accruedInterest);

        require(moneyMarket.redeemUnderlying(accruedInterest) == 0, "REDEEM_FROM_COMPOUND_FAILED");

        // Mint tokens to the patron
        projectToken.mint(address(patron), tokenAmount);

        // Send acrrued interest to the project.
        underlyingToken.safeTransfer(address(fundedProject), accruedInterest);
    }

    /**
    * @dev Withdraw amount of tokens to the patron's address according to the accrued interest.
    * On that point, the tokens are actually being created (minted) using the formula:
    * TOKEN_AMOUNT = ACCRUED_INTEREST * TOKEN_RATIO
    * Along with that interest with the value equal to the value of tokens being withdrawn are
    * transferred to the project's address.
    */
    function withdrawTokens(uint256 amount) public onlyOwner returns (uint256 redeemedAmount) {
        uint256 accruedInterest = getAccruedInterestInternal();

        uint256 maxTokenAmount = getTokenAmount(accruedInterest);

        require(maxTokenAmount >= amount, "WITHDRAW_TOKENS_AMOUNT_EXCEEDED");

        redeemedAmount = getFractionalAmount(accruedInterest, amount, maxTokenAmount);

        require(moneyMarket.redeemUnderlying(redeemedAmount) == 0, "REDEEM_FROM_COMPOUND_FAILED");

        // Mint tokens to the patron
        projectToken.mint(address(patron), amount);

        // Send acrrued interest to the project.
        underlyingToken.safeTransfer(address(fundedProject), redeemedAmount);
    }

    /**
    * @dev Withdraw the whole accrued interest to the project's
    * Along with that tokens with the value equal to the value of interest being withdrawn are
    * transferred to the patron's address.
    */
    function withdrawAccruedInterest() public onlyOwner returns (uint256 tokenAmount) {
        uint256 accruedInterest = getAccruedInterestInternal();

        tokenAmount = getTokenAmount(accruedInterest);

        require(moneyMarket.redeemUnderlying(accruedInterest) == 0, "REDEEM_FROM_COMPOUND_FAILED");

        // Send accrued interest to the project.
        underlyingToken.safeTransfer(address(fundedProject), accruedInterest);

        // Mint tokens to the patron
        projectToken.mint(address(patron), tokenAmount);
    }

    /**
    * @dev Withdraw specific amount of accrued interest to the project's
    * Along with that tokens with the value equal to the value of interest being withdrawn are
    * transferred to the patron's address.
    */
    function withdrawAccruedInterest(uint256 amount) public onlyOwner returns (uint256 tokenAmount) {
        uint256 accruedInterest = getAccruedInterestInternal();

        require(accruedInterest >= amount, "WITHDRAW_INTEREST_AMOUNT_EXCEEDED");

        uint256 maxTokenAmount = getTokenAmount(accruedInterest);

        tokenAmount = getFractionalAmount(maxTokenAmount, amount, accruedInterest);

        require(moneyMarket.redeemUnderlying(amount) == 0, "REDEEM_FROM_COMPOUND_FAILED");

        // Send interest to the project.
        underlyingToken.safeTransfer(address(fundedProject), amount);

        // Mint tokens to the patron
        projectToken.mint(address(patron), tokenAmount);
    }

    /**
    * @dev Calculates the token amount for the accrued interest.
    */
    function getTokenAmount() public view returns (uint256 tokenAmount) {
        uint256 accruedInterest = getAccruedInterest();
        tokenAmount = getTokenAmount(accruedInterest);
    }

    /**
    * @dev Calculates the token amount for given interest.
    */
    function getTokenAmount(uint256 accruedInterest) public view returns (uint256 tokenAmount) {
        tokenAmount = accruedInterest.mul(tokenRatio).div(PRECISION);
    }

    /**
    * @dev Calculates the accrued interest.
    */
    function getAccruedInterest() public view returns (uint256 accruedInterest) {
        uint256 cTokenBalance = moneyMarket.balanceOf(address(this));
        uint256 exchangeRate = moneyMarket.exchangeRateStored();
        uint256 actualBalance = cTokenBalance.mul(exchangeRate);
        accruedInterest = actualBalance.sub(totalInvestment);
    }

    /**
    * @dev Calculates the accrued interest by using balanceOfUnderlying
    */
    function getAccruedInterestInternal() internal returns (uint256 accruedInterest) {
        uint256 actualBalance = moneyMarket.balanceOfUnderlying(address(this));
        // Accrued interest is equal to the actual balance minus the initial investment.
        accruedInterest = actualBalance.sub(totalInvestment);
    }

    /**
    * @dev Calculates fractional amount for given inputs
    */
    function getFractionalAmount(
        uint256 numerator,
        uint256 target,
        uint256 denominator
    ) internal pure returns (uint256 fractionalAmount)
    {
        fractionalAmount = numerator.mul(target).div(denominator);
    }
}