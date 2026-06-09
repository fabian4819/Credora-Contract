// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IAgentPassport {
    function isAuthorizedOperator(uint256 agentId, address caller) external view returns (bool);
}

contract DecisionLogger {
    enum Action {
        Long,
        Short,
        Hold,
        Alert
    }

    struct Decision {
        uint256 agentId;
        uint256 seasonId;
        bytes32 marketHash;
        Action action;
        uint16 confidence;
        uint16 riskScore;
        uint64 targetWindowSeconds;
        bytes32 dataHash;
        bytes32 rationaleHash;
        string evidenceURI;
        uint64 submittedAt;
    }

    IAgentPassport public immutable passport;
    uint256 public nextDecisionId = 1;

    mapping(uint256 => Decision) public decisions;
    mapping(uint256 => uint256[]) private _agentDecisions;
    mapping(uint256 => uint256[]) private _seasonDecisions;

    event DecisionSubmitted(
        uint256 indexed decisionId,
        uint256 indexed agentId,
        uint256 indexed seasonId,
        bytes32 marketHash,
        Action action,
        uint16 confidence,
        uint16 riskScore,
        uint64 targetWindowSeconds,
        bytes32 dataHash,
        bytes32 rationaleHash,
        string evidenceURI
    );

    constructor(address passportAddress) {
        require(passportAddress != address(0), "ZERO_PASSPORT");
        passport = IAgentPassport(passportAddress);
    }

    function submitDecision(
        uint256 agentId,
        uint256 seasonId,
        bytes32 marketHash,
        Action action,
        uint16 confidence,
        uint16 riskScore,
        uint64 targetWindowSeconds,
        bytes32 dataHash,
        bytes32 rationaleHash,
        string calldata evidenceURI
    ) external returns (uint256 decisionId) {
        require(passport.isAuthorizedOperator(agentId, msg.sender), "NOT_AUTHORIZED_AGENT");
        require(confidence <= 100, "INVALID_CONFIDENCE");
        require(riskScore <= 100, "INVALID_RISK");
        require(targetWindowSeconds > 0, "INVALID_WINDOW");

        decisionId = nextDecisionId++;
        decisions[decisionId] = Decision({
            agentId: agentId,
            seasonId: seasonId,
            marketHash: marketHash,
            action: action,
            confidence: confidence,
            riskScore: riskScore,
            targetWindowSeconds: targetWindowSeconds,
            dataHash: dataHash,
            rationaleHash: rationaleHash,
            evidenceURI: evidenceURI,
            submittedAt: uint64(block.timestamp)
        });

        _agentDecisions[agentId].push(decisionId);
        _seasonDecisions[seasonId].push(decisionId);

        emit DecisionSubmitted(
            decisionId,
            agentId,
            seasonId,
            marketHash,
            action,
            confidence,
            riskScore,
            targetWindowSeconds,
            dataHash,
            rationaleHash,
            evidenceURI
        );
    }

    function getAgentDecisions(uint256 agentId) external view returns (uint256[] memory) {
        return _agentDecisions[agentId];
    }

    function getSeasonDecisions(uint256 seasonId) external view returns (uint256[] memory) {
        return _seasonDecisions[seasonId];
    }
}

