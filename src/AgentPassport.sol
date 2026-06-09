// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title AgentPassport
/// @notice ERC-8004-inspired agent identity. Minimal ERC721-like passport for hackathon demo.
contract AgentPassport {
    struct AgentConfig {
        string name;
        string strategyType;
        string metadataURI;
        address operator;
        bytes32 strategyHash;
        bool active;
        uint64 registeredAt;
    }

    string public constant name = "Credora Agent Passport";
    string public constant symbol = "CAP";

    uint256 public nextAgentId = 1;

    mapping(uint256 => AgentConfig) public agentConfigs;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event AgentRegistered(
        uint256 indexed agentId,
        address indexed owner,
        address indexed operator,
        string name,
        string strategyType,
        string metadataURI,
        bytes32 strategyHash
    );
    event AgentMetadataUpdated(uint256 indexed agentId, string metadataURI);
    event AgentOperatorUpdated(uint256 indexed agentId, address indexed operator);
    event AgentStatusUpdated(uint256 indexed agentId, bool active);

    modifier onlyAgentOwner(uint256 agentId) {
        require(ownerOf(agentId) == msg.sender, "NOT_AGENT_OWNER");
        _;
    }

    function registerAgent(
        string calldata agentName,
        string calldata strategyType,
        string calldata metadataURI,
        address operator,
        bytes32 strategyHash
    ) external returns (uint256 agentId) {
        require(bytes(agentName).length > 0, "EMPTY_AGENT_NAME");
        require(operator != address(0), "ZERO_OPERATOR");

        agentId = nextAgentId++;
        _owners[agentId] = msg.sender;
        _balances[msg.sender] += 1;

        agentConfigs[agentId] = AgentConfig({
            name: agentName,
            strategyType: strategyType,
            metadataURI: metadataURI,
            operator: operator,
            strategyHash: strategyHash,
            active: true,
            registeredAt: uint64(block.timestamp)
        });

        emit Transfer(address(0), msg.sender, agentId);
        emit AgentRegistered(agentId, msg.sender, operator, agentName, strategyType, metadataURI, strategyHash);
    }

    function updateAgentMetadata(uint256 agentId, string calldata metadataURI) external onlyAgentOwner(agentId) {
        agentConfigs[agentId].metadataURI = metadataURI;
        emit AgentMetadataUpdated(agentId, metadataURI);
    }

    function setAgentOperator(uint256 agentId, address operator) external onlyAgentOwner(agentId) {
        require(operator != address(0), "ZERO_OPERATOR");
        agentConfigs[agentId].operator = operator;
        emit AgentOperatorUpdated(agentId, operator);
    }

    function setAgentStatus(uint256 agentId, bool active) external onlyAgentOwner(agentId) {
        agentConfigs[agentId].active = active;
        emit AgentStatusUpdated(agentId, active);
    }

    function tokenURI(uint256 agentId) external view returns (string memory) {
        require(_owners[agentId] != address(0), "NOT_MINTED");
        return agentConfigs[agentId].metadataURI;
    }

    function isAuthorizedOperator(uint256 agentId, address caller) external view returns (bool) {
        AgentConfig storage config = agentConfigs[agentId];
        return config.active && (caller == ownerOf(agentId) || caller == config.operator);
    }

    function ownerOf(uint256 tokenId) public view returns (address owner) {
        owner = _owners[tokenId];
        require(owner != address(0), "NOT_MINTED");
    }

    function balanceOf(address owner) external view returns (uint256) {
        require(owner != address(0), "ZERO_OWNER");
        return _balances[owner];
    }

    function approve(address approved, uint256 tokenId) external {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner || _operatorApprovals[owner][msg.sender], "NOT_APPROVED");
        _tokenApprovals[tokenId] = approved;
        emit Approval(owner, approved, tokenId);
    }

    function getApproved(uint256 tokenId) external view returns (address) {
        require(_owners[tokenId] != address(0), "NOT_MINTED");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) external {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return _operatorApprovals[owner][operator];
    }
}

