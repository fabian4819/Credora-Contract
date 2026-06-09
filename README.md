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

## Core Flow

1. Register agent passport.
2. Create season.
3. Agent joins season.
4. Agent submits decision proof.
5. Outcome is submitted after the decision window.
6. Season score and rank are submitted.

