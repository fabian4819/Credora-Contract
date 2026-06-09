// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ReputationEngine {
    struct SeasonScore {
        uint256 decisions;
        uint256 successes;
        uint256 failures;
        uint256 neutrals;
        int256 totalRoiBps;
        uint256 totalRiskScore;
        uint256 finalScore;
        uint256 rank;
        bool finalized;
    }

    address public owner;
    mapping(address => bool) public scoreSubmitters;
    mapping(uint256 => mapping(uint256 => SeasonScore)) public seasonScores;

    event ScoreSubmitterUpdated(address indexed submitter, bool allowed);
    event SeasonScoreSubmitted(
        uint256 indexed seasonId,
        uint256 indexed agentId,
        uint256 decisions,
        uint256 successes,
        uint256 failures,
        uint256 neutrals,
        int256 totalRoiBps,
        uint256 totalRiskScore,
        uint256 finalScore
    );
    event SeasonRankSubmitted(uint256 indexed seasonId, uint256 indexed agentId, uint256 rank);

    modifier onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");
        _;
    }

    modifier onlyScoreSubmitter() {
        require(scoreSubmitters[msg.sender], "NOT_SCORE_SUBMITTER");
        _;
    }

    constructor() {
        owner = msg.sender;
        scoreSubmitters[msg.sender] = true;
    }

    function setScoreSubmitter(address submitter, bool allowed) external onlyOwner {
        scoreSubmitters[submitter] = allowed;
        emit ScoreSubmitterUpdated(submitter, allowed);
    }

    function submitSeasonScore(
        uint256 seasonId,
        uint256 agentId,
        uint256 decisions,
        uint256 successes,
        uint256 failures,
        uint256 neutrals,
        int256 totalRoiBps,
        uint256 totalRiskScore,
        uint256 finalScore
    ) external onlyScoreSubmitter {
        require(decisions == successes + failures + neutrals, "INVALID_COUNTS");
        require(finalScore <= 10000, "INVALID_SCORE");

        SeasonScore storage score = seasonScores[seasonId][agentId];
        score.decisions = decisions;
        score.successes = successes;
        score.failures = failures;
        score.neutrals = neutrals;
        score.totalRoiBps = totalRoiBps;
        score.totalRiskScore = totalRiskScore;
        score.finalScore = finalScore;
        score.finalized = true;

        emit SeasonScoreSubmitted(
            seasonId,
            agentId,
            decisions,
            successes,
            failures,
            neutrals,
            totalRoiBps,
            totalRiskScore,
            finalScore
        );
    }

    function submitSeasonRank(uint256 seasonId, uint256 agentId, uint256 rank) external onlyScoreSubmitter {
        require(seasonScores[seasonId][agentId].finalized, "SCORE_NOT_FINALIZED");
        seasonScores[seasonId][agentId].rank = rank;
        emit SeasonRankSubmitted(seasonId, agentId, rank);
    }

    function getSeasonScore(uint256 seasonId, uint256 agentId) external view returns (SeasonScore memory) {
        return seasonScores[seasonId][agentId];
    }
}
