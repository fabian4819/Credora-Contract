// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../src/AgentPassport.sol";
import "../src/DecisionLogger.sol";
import "../src/OutcomeRegistry.sol";
import "../src/ReputationEngine.sol";
import "../src/SeasonManager.sol";

contract DeployScript {
    AgentPassport public passport;
    DecisionLogger public decisionLogger;
    OutcomeRegistry public outcomeRegistry;
    ReputationEngine public reputationEngine;
    SeasonManager public seasonManager;

    function run() external {
        passport = new AgentPassport();
        decisionLogger = new DecisionLogger(address(passport));
        outcomeRegistry = new OutcomeRegistry();
        reputationEngine = new ReputationEngine();
        seasonManager = new SeasonManager();
    }
}

