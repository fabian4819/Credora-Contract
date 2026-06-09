// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../src/AgentPassport.sol";
import "../src/DecisionLogger.sol";
import "../src/OutcomeRegistry.sol";
import "../src/ReputationEngine.sol";
import "../src/SeasonManager.sol";

contract CredoraFlowTest {
    AgentPassport passport;
    DecisionLogger decisionLogger;
    OutcomeRegistry outcomeRegistry;
    ReputationEngine reputationEngine;
    SeasonManager seasonManager;

    function setUp() public {
        passport = new AgentPassport();
        decisionLogger = new DecisionLogger(address(passport));
        outcomeRegistry = new OutcomeRegistry();
        reputationEngine = new ReputationEngine();
        seasonManager = new SeasonManager();
    }

    function testRegisterAgentSubmitDecisionAndOutcome() public {
        uint256 agentId = passport.registerAgent(
            "MNTScout",
            "momentum",
            "ipfs://agent-metadata",
            address(this),
            keccak256(bytes("momentum-v1"))
        );

        uint256 seasonId = seasonManager.createSeason("Mantle AI Alpha Challenge", 1, 7 days, "MNT markets");
        seasonManager.joinSeason(seasonId, agentId);

        uint256 decisionId = decisionLogger.submitDecision(
            agentId,
            seasonId,
            keccak256(bytes("MNT/USDT")),
            DecisionLogger.Action.Long,
            78,
            42,
            4 hours,
            keccak256(bytes("snapshot")),
            keccak256(bytes("rationale")),
            "ipfs://evidence"
        );

        uint256 outcomeId = outcomeRegistry.submitOutcome(
            decisionId,
            agentId,
            seasonId,
            OutcomeRegistry.OutcomeStatus.Success,
            310,
            82,
            keccak256(bytes("metrics")),
            "ipfs://outcome"
        );

        OutcomeRegistry.Outcome memory outcome = outcomeRegistry.getDecisionOutcome(decisionId);
        require(outcome.decisionId == decisionId, "bad decision id");
        require(outcomeId == 1, "bad outcome id");
    }

    function testSubmitSeasonScore() public {
        reputationEngine.submitSeasonScore(1, 1, 3, 2, 1, 0, 450, 120, 7825);
        reputationEngine.submitSeasonRank(1, 1, 1);

        ReputationEngine.SeasonScore memory score = reputationEngine.getSeasonScore(1, 1);
        require(score.decisions == 3, "bad decisions");
        require(score.finalScore == 7825, "bad score");
        require(score.rank == 1, "bad rank");
    }
}
