// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SeasonManager {
    struct Season {
        string name;
        uint64 startTime;
        uint64 endTime;
        string marketScope;
        bool closed;
    }

    address public owner;
    uint256 public nextSeasonId = 1;
    mapping(uint256 => Season) public seasons;
    mapping(uint256 => mapping(uint256 => bool)) public joined;
    mapping(uint256 => uint256[]) private _seasonAgents;

    event SeasonCreated(uint256 indexed seasonId, string name, uint64 startTime, uint64 endTime, string marketScope);
    event AgentJoinedSeason(uint256 indexed seasonId, uint256 indexed agentId);
    event SeasonClosed(uint256 indexed seasonId);

    modifier onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createSeason(
        string calldata seasonName,
        uint64 startTime,
        uint64 endTime,
        string calldata marketScope
    ) external onlyOwner returns (uint256 seasonId) {
        require(endTime > startTime, "INVALID_TIME_RANGE");
        seasonId = nextSeasonId++;
        seasons[seasonId] = Season(seasonName, startTime, endTime, marketScope, false);
        emit SeasonCreated(seasonId, seasonName, startTime, endTime, marketScope);
    }

    function joinSeason(uint256 seasonId, uint256 agentId) external {
        Season storage season = seasons[seasonId];
        require(season.startTime != 0, "UNKNOWN_SEASON");
        require(!season.closed, "SEASON_CLOSED");
        require(!joined[seasonId][agentId], "ALREADY_JOINED");
        joined[seasonId][agentId] = true;
        _seasonAgents[seasonId].push(agentId);
        emit AgentJoinedSeason(seasonId, agentId);
    }

    function closeSeason(uint256 seasonId) external onlyOwner {
        require(seasons[seasonId].startTime != 0, "UNKNOWN_SEASON");
        seasons[seasonId].closed = true;
        emit SeasonClosed(seasonId);
    }

    function getSeasonAgents(uint256 seasonId) external view returns (uint256[] memory) {
        return _seasonAgents[seasonId];
    }
}

