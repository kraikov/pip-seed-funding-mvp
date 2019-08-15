# The Public Interest Project
Public Interest Project, or PIP - a new on-chain seed funding mechanism.

The below is a summary of the PIP mechanism.  To read the full paper, click **here** (add link when ready)

# Introduction
As ICOs grew in popularity during the 2017 crypto bull market, the structural problems of ICOs were magnified and abused.  The main criticism of ICOs is that funds are received in one lump sum.  This makes it convenient for scams to occur and removes the concept of milestone-based funding.  In traditional financing, teams raise small seed funds and then raise larger funds through Series A, B, C and so on. Subsequent fundraises only occur if teams achieve milestones and build investor confidence.  With the popularization of ICOs, the concept of seed rounds for crypto projects financed by crypto participants have been largely overlooked.

The Public Interest Project (PIP) is a fully onchain seed funding mechanism which solves the many issues with ICOs while removing the risk of losing the patron’s principle, assuming the smart contract is correctly built. (Contributors to PIPs will be referred to as patrons because it is important to make the distinction that patrons are not investors.)

The PIP is simply an addition to ideas already being discussed and implemented in the crypto community such as by [PoolTogether](https://github.com/pooltogether/pooltogether-contracts/tree/master/contracts), [ZeframLou](https://github.com/ZeframLou/pooled-cdai), [PaulRBerg](https://github.com/ethereum/EIPs/issues/2212), [rDai](https://twitter.com/pet3rpan_/status/1161376583950540800?s=09), and probably many others out there who have similar ideas.

# How it Works (Simplified)
PIPs fund projects in a way that, assuming the PIP smart contracts are secure, are risk free to the patron. This is an extremely beneficial property of PIPs given that the risk of losing invested capital is highest during the earliest phases of a project, such as a seed round.  If the team proves themselves to the crypto community during the PIP phase, they can choose to conduct a follow on funding via a [DAICO](https://ethresear.ch/t/explanation-of-daicos/465).  

The below is a simplified explanation of how the PIP works.  The following section describes how it works in more detail.  Simplified version:  

-	A token project deploys a smart contract which interacts with the Compound protocol. Patrons can then send assets to the smart contract.
-	The interest yielded from the patrons’ assets in the smart contract are then sent to the token project, creating a stream of interest funding for the token project.
-	The smart contract will send back an equivalent amount of the project’s native token to the patron based on the interested yielded from that individual patron’s staked assets.
-	The token project (or anyone else) can create a market on Uniswap for the token to create a pool of liquidity for patrons to trade with. This price discovery would result in a market rate for the token to derive the amount of tokens necessary to send back to the PIP patrons.

To help tie the PIP mechanism together, let’s go through a simple example. Alice, Bob, and Carol decide to pool their assets to fund Project XYZ and in return will receive XYZ tokens. Alice sends 200,000 DAI, Bob sends 300,000 DAI, and Carol sends 500,000 DAI for a total of 1,000,000 DAI in the PIP smart contract. In this example, assume that the interest rate (APR) is 10%. For simplicity, assume that the interest is paid daily and the project’s tokens are returned daily. Finally, assume the price of XYZ token is equivalent to $0.5 USD and that DAI is equivalent to $1.00 USD. The diagram below shows how this would play out: 

![abstract-workflow-diagram](https://github.com/kraikov/pip-seed-funding-mvp/blob/master/docs/abstract-workflow-diagram.png)

# Technical Details
This repo contains sample **unaudited** smart contracts for the PIP. These are meant to help others get started quickly but **are not** audited and **should not** be used without further due dilligence.

The following smart contracts represent the idea explained above:

- PIPController.sol - the patrons and the project will interract only with this contract. The project specifics are handled in the PipConfig.sol file. There you can specify the token ratio (e.g. 1 TOKEN = 0.1 DAI), the money market (e.g. cDAI), the underlying asset (e.g. DAI), the project's token address and the project's wallet address where the interest is transferred. Once the contract is deployed by the project patrons can start funding the contract and accumulate interest for the project and project's tokens for themselves. For every patron a `createNewPip()` function is called and thus creating a new `Pip` contract instance. To supply money to the market, the patron is calling the `fund` function and specifying the desired amount. The controller makes sure it picks the right `Pip` contract instance (the one assigned to the patron) and then the PIP contract instance interracts with the Compound Protocol by minting new cTokens. At any given point, any patron can make a refund by calling the `refund` function and specifying the desired amount. This will redeem the underlying asset from the `Compound Money Market` and will send only the initial funding provided by the patron. The accumulated interest will be send to the project and the equivalent amount of tokens will be send to the patron.
At any given point, any patron can withdraw the accumulated tokens by calling the `withdrawTokens` function and specifying the desired amount. The accrued interest is calculated and based on it, the amount of accrued tokens is also calculated. The tokens are trasnferred to the patron and the interest to the project.
At any given point, the project can withdraw the accrued interest by calling the function `withdrawAccruedInterest`. The function has 2 overloads:
  - `withdrawAccruedInterest(uint256 amount, address patron)` - it withdraws the desired amount from a given patron. 
  - `withdrawAccruedInterest(uint256 from, uint256 to)` - iterates the list of patrons so it can withdraw the interest at once (if possible - if there are too much patrons, then it will take multiple calls until all of them are iterated).
Both `withdrawAccruedInterest` functions calculates the accrued interest and based on it, the amount of accrued tokens. Once again - the tokens are transferred to the patron and the interest to the project.

- Pip.sol - for every patron a new instance of that contract is created through the PipController. The contract interracts directly with the Compound protocol and handles all the logic of `fund`, `refund`, `withdrawAccruedInterest` and `withdrawTokens`.

TL;DR - the following sequence diagrams describes the whole flow:

### Fund and refund sequence diagrams. Initiated by the Patron at any time.
![fund-refund-diagram](https://github.com/kraikov/pip-seed-funding-mvp/blob/master/docs/fund-refund-diagram.png)
 
 ### Withdraw Interest and Tokens sequence diagrams. Initiated by the funded Project and the Patrons at any time.
![interest-tokens-withdraw-diagram](https://github.com/kraikov/pip-seed-funding-mvp/blob/master/docs/interest-token-withdraw-diagram.png)


# Closing Thoughts

The bull market of 2017 created a massive spike in popularity of ICOs.  Although ICOs have helped enable massive innovation for the crypto industry, the structural flaws of the ICO have been abused by scammers, have rewarded teams without any milestone structure, and have unfortunately led to many investors losing funds. 

PIPs act as a seed round for crypto projects to get the project off the ground.  Through this process, teams can prove themselves to the broader crypto community before taking on further funding.  PIPs, assuming the smart contracts work as intended, remove the risk of losing patrons’ capital since funds are contributed through interest yielded on the staked capital.  

The PIP is an example of how the crypto ecosystem can self-regulate and self-correct and move together towards more responsible mechanisms. Hopefully the PIP can serve as a seed funding option to help further the innovation of the crypto ecosystem at large while protecting patrons’ capital.
