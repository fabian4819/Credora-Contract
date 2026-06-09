// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract OutcomeRegistry {
    enum OutcomeStatus {
        Pending,
        Success,
        Failed,
        Neutral,
        Inconclusive
    }

    struct Outcome {
        uint256 decisionId;
        uint256 agentId;
        uint256 seasonId;
        OutcomeStatus status;
        int256 roiBps;
        uint16 confidenceCalibration;
        bytes32 metricsHash;
        string evidenceURI;
        uint64 submittedAt;
    }

    address public owner;
    uint256 public nextOutcomeId = 1;

    mapping(address => bool) public outcomeSubmitters;
    mapping(uint256 => Outcome) public outcomes;
    mapping(uint256 => uint256) public decisionOutcomeId;
    mapping(uint256 => uint256[]) private _agentOutcomes;
    mapping(uint256 => uint256[]) private _seasonOutcomes;

    event OutcomeSubmitterUpdated(address indexed submitter, bool allowed);
    event OutcomeSubmitted(
        uint256 indexed outcomeId,
        uint256 indexed decisionId,
        uint256 indexed agentId,
        uint256 seasonId,
        OutcomeStatus status,
        int256 roiBps,
        uint16 confidenceCalibration,
        bytes32 metricsHash,
        string evidenceURI
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");
        _;
    }

    modifier onlyOutcomeSubmitter() {
        require(outcomeSubmitters[msg.sender], "NOT_OUTCOME_SUBMITTER");
        _;
    }

    constructor() {
        owner = msg.sender;
        outcomeSubmitters[msg.sender] = true;
    }

    function setOutcomeSubmitter(address submitter, bool allowed) external onlyOwner {
        outcomeSubmitters[submitter] = allowed;
        emit OutcomeSubmitterUpdated(submitter, allowed);
    }

    function submitOutcome(
        uint256 decisionId,
        uint256 agentId,
        uint256 seasonId,
        OutcomeStatus status,
        int256 roiBps,
        uint16 confidenceCalibration,
        bytes32 metricsHash,
        string calldata evidenceURI
    ) external onlyOutcomeSubmitter returns (uint256 outcomeId) {
        require(decisionId != 0, "INVALID_DECISION");
        require(decisionOutcomeId[decisionId] == 0, "OUTCOME_EXISTS");
        require(confidenceCalibration <= 100, "INVALID_CALIBRATION");

        outcomeId = nextOutcomeId++;
        outcomes[outcomeId] = Outcome({
            decisionId: decisionId,
            agentId: agentId,
            seasonId: seasonId,
            status: status,
            roiBps: roiBps,
            confidenceCalibration: confidenceCalibration,
            metricsHash: metricsHash,
            evidenceURI: evidenceURI,
            submittedAt: uint64(block.timestamp)
        });

        decisionOutcomeId[decisionId] = outcomeId;
        _agentOutcomes[agentId].push(outcomeId);
        _seasonOutcomes[seasonId].push(outcomeId);

        emit OutcomeSubmitted(
            outcomeId,
            decisionId,
            agentId,
            seasonId,
            status,
            roiBps,
            confidenceCalibration,
            metricsHash,
            evidenceURI
        );
    }

    function getDecisionOutcome(uint256 decisionId) external view returns (Outcome memory) {
        uint256 outcomeId = decisionOutcomeId[decisionId];
        require(outcomeId != 0, "NO_OUTCOME");
        return outcomes[outcomeId];
    }

    function getAgentOutcomes(uint256 agentId) external view returns (uint256[] memory) {
        return _agentOutcomes[agentId];
    }

    function getSeasonOutcomes(uint256 seasonId) external view returns (uint256[] memory) {
        return _seasonOutcomes[seasonId];
    }
}

