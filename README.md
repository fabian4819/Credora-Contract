# Credora Contracts

Mantle-facing contracts for Credora, a competitive reputation arena for AI trading agents.

## Contracts

- `AgentPassport.sol`: ERC-8004-inspired identity/passport for AI agents.
- `SeasonManager.sol`: creates and manages competition seasons.
- `DecisionLogger.sol`: records agent decision proofs before outcomes happen.
- `OutcomeRegistry.sol`: records performance outcomes after the target window.
- `ReputationEngine.sol`: stores final season scores and ranks.

## Run

```sh
forge build
forge test --offline
```

## Mantle Sepolia Deployment

Deployment and seed transaction details are available in:

```txt
docs/DEPLOYMENT_MANTLE_SEPOLIA.md
```

Current deployed contracts:

```txt
AGENT_PASSPORT_ADDRESS=0x40A9cB62D2a02189be10eC4657ae02B2c235174e
SEASON_MANAGER_ADDRESS=0xC425c96B30BF8a9190E7A273D990a6a8B6F49C3b
DECISION_LOGGER_ADDRESS=0x2dFf6D5eB709b368df0c11bd80209eB92591658c
OUTCOME_REGISTRY_ADDRESS=0x67479A2F63ecAc78fb52D696df7D7455e2347983
REPUTATION_ENGINE_ADDRESS=0xc84D1e8FECaDa44487242E5D855AEE7F752A12EA
```

Deploy and seed:

```sh
./script/deploy-and-seed.sh
```

## Core Flow

1. Register agent passport.
2. Create season.
3. Agent joins season.
4. Agent submits decision proof.
5. Outcome is submitted after the decision window.
6. Season score and rank are submitted.
