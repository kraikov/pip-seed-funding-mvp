pragma solidity >=0.4.21 <0.6.0;

contract PipConfig {
    // The MVP works with fixed token ratio, but the ratio can be easily tracked from Uniswap for example.
    uint256 constant internal TOKEN_RATIO = 10 ** 19; // 1 DAI = 10 tokens

    // The MVP works with cDAI only, but other markets can be easily added.
    address constant internal MONEY_MARKET = address(0xF5DCe57282A584D2746FaF1593d3121Fcac444dC);

    address constant internal UNDERLYING_TOKEN = address(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);

    // The project's token that will be minted for every patron's accrued interest
    address constant internal PROJECT_TOKEN = address(0x0);

    // The project's token that will be minted for every patron's accrued interest
    address constant internal PROJECT_WALLET = address(0x0);
}