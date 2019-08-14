# pip-seed-funding-mvp
Public Interest Project, or PIP - a new on-chain seed funding mechanism.

The below is a summary of the PIP mechanism.  To read the full paper, click **here** (add link when ready)

# Introduction
The Initial Coin Offering (ICO) is a popular funding method for crypto projects to raise capital.  In an ICO, crypto projects sell their native tokens in exchange for Ether (or other tokens) to investors.  Although ICOs can be incredibly helpful in funding innovation, they have many structural problems which were magnified as the popularity of ICOs grew during the 2017 crypto bull market.  

The main criticism of ICOs is that funds are received in one lump sum.  This makes it convenient for scams to occur and removes the concept of milestone-based funding.  In traditional financing, teams raise small seed funds and then raise larger funds through Series A, B, C and so on. Subsequent fundraises only occur if teams achieve milestones and build investor confidence.  With the popularization of ICOs, the concept of seed rounds for crypto projects financed by crypto participants have been largely overlooked.

The Public Interest Project (PIP) is a fully onchain seed funding mechanism which solves the many issues with ICOs while removing the risk of losing the patron’s principle, assuming the smart contract is correctly built.  

# How it Works - **Krasimir to help revise this section**:

PIPs fund projects in a way that, assuming the PIP smart contracts are secure, are risk free to the patron. This is an extremely beneficial property of PIPs given that the risk of losing invested capital is highest during the earliest phases of a project, such as a seed round.  If the team proves themselves to the crypto community during the PIP phase, they can choose to conduct a follow on funding via a [DAICO](https://ethresear.ch/t/explanation-of-daicos/465).  

The PIP is simply an addition to ideas already being discussed and implemented in the crypto community such as by [PoolTogether](https://github.com/pooltogether/pooltogether-contracts/tree/master/contracts), [ZeframLou](https://github.com/ZeframLou/pooled-cdai), [PaulRBerg](https://github.com/ethereum/EIPs/issues/2212), [rDai](https://twitter.com/pet3rpan_/status/1161376583950540800?s=09), and probably many others out there who have similar ideas.

The mechanisms of PIPs are quite simple:  

-	A token project deploys a smart contract which interacts with the Compound protocol.  Patrons can then send assets to the smart contract.  
-	The interest yielded from the patrons’ assets in the smart contract are then sent to the token project, creating a stream of interest funding for the token project.
-	The smart contract will send back an equivalent amount of the project’s native token to the patron based on the interested yielded from that individual patron’s staked assets.
-	The token project (or anyone else) can create a market on Uniswap for the token to create a pool of liquidity for patrons to trade with. This price discovery would result in a market rate for the token to derive the amount of tokens necessary to send back to the PIP patrons.  

To help tie the PIP mechanism together, let’s go through a simple example.  Alice, Bob, and Carol decide to pool their assets to fund Project XYZ and in return will receive XYZ tokens.  Alice sends 200,000 DAI, Bob sends 300,000 DAI, and Carol sends 500,000 DAI for a total of 1,000,000 DAI in the PIP smart contract.  In this example, assume that the interest rate (APR) is 10%.  Also assume that the interest is paid daily and the project’s tokens are returned daily (in reality, this would happen per block).  Finally, assume the price of XYZ token is equivalent to $0.5 USD and that DAI is equivalent to $1.00 USD.  The diagram below shows how this would play out. 

### Fund and refund sequence diagrams. Initiated by the Patron at any time.
![fund-refund-diagram](https://github.com/kraikov/pip-seed-funding-mvp/blob/master/docs/fund-refund-diagram.png)
 
 ### Withdraw Interest and Tokens sequence diagrams. Initiated by the funded Project and the Patrons at any time.
![interest-tokens-withdraw-diagram](https://github.com/kraikov/pip-seed-funding-mvp/blob/master/docs/interest-token-withdraw-diagram.png)

# PIP Seed Funding Benefits and Limitations

The PIP solves many of the problems that ICOs have been criticized for.  Assuming the PIP smart contracts are working as intended and that the price of DAI remains at $1 USD, the benefits of PIPs are:

-	PIPs are a way for token projects to access seed funding fully onchain.  If the project proves itself and builds investor confidence, it can choose to do a follow on round through a DAICO.  This will help filter projects more effectively.  
-	Typically, the earlier that funding occurs, the riskier it is.  The PIP removes the risk from seed round financing because funds are only sent via interest on the patron’s capital. The patron only “loses” out on the opportunity cost of having invested that capital elsewhere.  To compensate for this, the patron receives tokens from the token project equivalent to the interested gifted.  
-	PIPs essentially introduce milestone based funding to crypto financing because patrons can remove or add more assets to the PIP contract depending on their assessment of the project’s development.  This should create more motivation for teams to continue to build versus the lump sum model of ICOs.
-	PIPs reopen funding opportunity to all who wish to participate because this is done entirely on the Ethereum blockchain, without reliance on outside entities.  
-	Projects funded through PIPs are not dependent upon centralized exchanges to provide liquidity.  Projects can simply create their own uniswap market from the beginning if they want.

Although PIPs carry many benefits, there are also limitations and unknowns which are:

-	Given that funding is sent as interest yielded from staked assets, the amount funding a project may not reach very high amounts.  This could arguably be a positive, as some of the ICO fundraises in the recent past were questionably large.  Given that PIPs are meant to address the lack of seed funding mechanisms in the crypto market, the lower fund size is to be expected.
-	If PIPs as a fundraising mechanism were to grow rapidly, it would introduce a large influx of loans supplied to the Compound protocol.  All else equal, this would push the interest rates down for these assets.  There may be a ceiling in the short term on how many projects could simultaneously run large PIPs.    
-	If interest rates dropped drastically, it would create strain for the projects funded through a PIP.  However, this does not differ much when compared to projects funded through Ether or other cryptos, which have declined drastically in price since the peak of the previous bull market.  As always, responsible capital management is essential.
-	The DeFi ecosystem is relatively brand new.  There are still a lot of unknowns that could create unforeseen side effects from an influx of loan supply.

# Closing Thoughts

The bull market of 2017 created a massive spike in popularity of ICOs.  Although ICOs have helped enable massive innovation for the crypto industry, the structural flaws of the ICO have been abused by scammers, have rewarded teams without any milestone structure, and have unfortunately led to many investors losing funds. 

PIPs act as a seed round for crypto projects to get the project off the ground.  Through this process, teams can prove themselves to the broader crypto community before taking on further funding.  PIPs, assuming the smart contracts work as intended, remove the risk of losing patrons’ capital since funds are contributed through interest yielded on the staked capital.  The PIP is an example of how the crypto ecosystem can self-regulate and self-correct and move together towards more responsible mechanisms. Hopefully the PIP can serve as a seed funding option to help further the innovation of the crypto ecosystem at large while protecting patrons’ capital.
