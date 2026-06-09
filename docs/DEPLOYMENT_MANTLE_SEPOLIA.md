# Credora Mantle Sepolia Deployment

Network:

```txt
Mantle Sepolia
Chain ID: 5003
RPC: https://rpc.sepolia.mantle.xyz
Explorer: https://explorer.sepolia.mantle.xyz
```

## Contract Addresses

```txt
AGENT_PASSPORT_ADDRESS=0x40A9cB62D2a02189be10eC4657ae02B2c235174e
SEASON_MANAGER_ADDRESS=0xC425c96B30BF8a9190E7A273D990a6a8B6F49C3b
DECISION_LOGGER_ADDRESS=0x2dFf6D5eB709b368df0c11bd80209eB92591658c
OUTCOME_REGISTRY_ADDRESS=0x67479A2F63ecAc78fb52D696df7D7455e2347983
REPUTATION_ENGINE_ADDRESS=0xc84D1e8FECaDa44487242E5D855AEE7F752A12EA
```

## Seed Transactions

```txt
REGISTER_AGENT_TX=0x389ec7df648bea3fec3227c162bb716bd3dee49724126240b5a584d720418dd3
CREATE_SEASON_TX=0x5baaec2c1f22d6ad96e3ab1c6367c3e7e07189f6e0ee0e86fad742c3be63f4b4
JOIN_SEASON_TX=0x932a7661ad6cdaf5ff29dffdc272617a516b5c94a569528f1e4c7f4232b473b8
SUBMIT_DECISION_TX=0xabf8c2bf714512d201c5b19927017806e0213079ab2ed0c045239d0fecec27df
SUBMIT_OUTCOME_TX=0x20275306eeaa6b41f20026febbdd62492f982b54dd0425af2721ec337ba0c0fc
SUBMIT_SCORE_TX=0x2d1f884d7dfa156880f2ea7d0831037d327add49417080203af35b3833fa4ba7
SUBMIT_RANK_TX=0x1a0ddfccc6f6cb33f39b18bc4ecf92be746f998ed0f12814429493115ed6a9ef
```

## Verification Status

All deployed contracts are verified on Sourcify with `exact_match`.

```txt
AgentPassport: 0x40A9cB62D2a02189be10eC4657ae02B2c235174e
SeasonManager: 0xC425c96B30BF8a9190E7A273D990a6a8B6F49C3b
DecisionLogger: 0x2dFf6D5eB709b368df0c11bd80209eB92591658c
OutcomeRegistry: 0x67479A2F63ecAc78fb52D696df7D7455e2347983
ReputationEngine: 0xc84D1e8FECaDa44487242E5D855AEE7F752A12EA
```

Verification settings:

```txt
solc: 0.8.24
optimizer: true
optimizer_runs: 200
verifier: sourcify
chain: 5003
```

DecisionLogger constructor args:

```txt
0x00000000000000000000000040a9cb62d2a02189be10ec4657ae02b2c235174e
```

## Explorer Links

AgentPassport:

```txt
https://explorer.sepolia.mantle.xyz/address/0x40A9cB62D2a02189be10eC4657ae02B2c235174e
```

DecisionLogger:

```txt
https://explorer.sepolia.mantle.xyz/address/0x2dFf6D5eB709b368df0c11bd80209eB92591658c
```

Demo decision transaction:

```txt
https://explorer.sepolia.mantle.xyz/tx/0xabf8c2bf714512d201c5b19927017806e0213079ab2ed0c045239d0fecec27df
```

Demo outcome transaction:

```txt
https://explorer.sepolia.mantle.xyz/tx/0x20275306eeaa6b41f20026febbdd62492f982b54dd0425af2721ec337ba0c0fc
```

## Verified Read Calls

Agent owner:

```txt
ownerOf(1) = 0x77CdB00BB76e341342E8a34Ec75F9addf9a76EEA
```

Agent decisions:

```txt
getAgentDecisions(1) = [1]
```

Decision outcome:

```txt
getDecisionOutcome(1) = Success, roiBps=480, confidenceCalibration=94
```
