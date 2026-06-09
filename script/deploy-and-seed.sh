#!/usr/bin/env bash
set -euo pipefail

if [ -f .env ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"
    line="$(printf '%s' "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [ -z "$line" ] && continue
    key="$(printf '%s' "$line" | sed 's/[[:space:]]*=.*$//')"
    value="$(printf '%s' "$line" | sed 's/^[^=]*=[[:space:]]*//')"
    value="$(printf '%s' "$value" | sed 's/^["'\"']//;s/["'\"']$//')"
    export "$key=$value"
  done < .env
fi

: "${PRIVATE_KEY:?PRIVATE_KEY is required in .env}"

RPC_URL="${MANTLE_RPC_URL:-https://rpc.sepolia.mantle.xyz}"
DEPLOYER_ADDRESS="$(cast wallet address --private-key "$PRIVATE_KEY")"
NEXT_NONCE="$(cast nonce "$DEPLOYER_ADDRESS" --rpc-url "$RPC_URL")"

CURRENT_NONCE=""
DEPLOYED_ADDRESS=""
take_nonce() {
  CURRENT_NONCE="$NEXT_NONCE"
  NEXT_NONCE=$((NEXT_NONCE + 1))
}

deploy() {
  local contract="$1"
  shift || true
  take_nonce
  DEPLOYED_ADDRESS="$(forge create "src/${contract}.sol:${contract}" \
    --rpc-url "$RPC_URL" \
    --private-key "$PRIVATE_KEY" \
    --nonce "$CURRENT_NONCE" \
    --broadcast \
    "$@" \
    --json 2>&1 | node -e 'let s="";process.stdin.on("data",d=>s+=d);process.stdin.on("end",()=>{const text=s.toString(); const textMatch=text.match(/Deployed to:\s*(0x[a-fA-F0-9]{40})/); if(textMatch){console.log(textMatch[1]); return} const jsonMatch=text.match(/\{[\s\S]*\}/); if(!jsonMatch){console.error(text); process.exit(1)} const j=JSON.parse(jsonMatch[0]); const address=j.deployedTo||j.deployed_to||j.address||j.contractAddress; if(!address){console.error(JSON.stringify(j,null,2)); process.exit(1)} console.log(address);})')"
}

send() {
  take_nonce
  cast send "$@" --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY" --nonce "$CURRENT_NONCE" --json
}

echo "Deploying Credora contracts to Mantle Sepolia..."

deploy AgentPassport
AGENT_PASSPORT_ADDRESS="$DEPLOYED_ADDRESS"
echo "AGENT_PASSPORT_ADDRESS=$AGENT_PASSPORT_ADDRESS"

deploy SeasonManager
SEASON_MANAGER_ADDRESS="$DEPLOYED_ADDRESS"
echo "SEASON_MANAGER_ADDRESS=$SEASON_MANAGER_ADDRESS"

deploy OutcomeRegistry
OUTCOME_REGISTRY_ADDRESS="$DEPLOYED_ADDRESS"
echo "OUTCOME_REGISTRY_ADDRESS=$OUTCOME_REGISTRY_ADDRESS"

deploy ReputationEngine
REPUTATION_ENGINE_ADDRESS="$DEPLOYED_ADDRESS"
echo "REPUTATION_ENGINE_ADDRESS=$REPUTATION_ENGINE_ADDRESS"

deploy DecisionLogger --constructor-args "$AGENT_PASSPORT_ADDRESS"
DECISION_LOGGER_ADDRESS="$DEPLOYED_ADDRESS"
echo "DECISION_LOGGER_ADDRESS=$DECISION_LOGGER_ADDRESS"

echo "Seeding explorer-visible activity..."

STRATEGY_HASH="$(cast keccak "momentum-v1")"
MARKET_HASH="$(cast keccak "MNT/USDT")"
DATA_HASH="$(cast keccak "credora-demo-snapshot")"
RATIONALE_HASH="$(cast keccak "credora-demo-rationale")"
METRICS_HASH="$(cast keccak "credora-demo-outcome-metrics")"

START_TIME="$(date +%s)"
END_TIME="$((START_TIME + 604800))"

send "$AGENT_PASSPORT_ADDRESS" \
  'registerAgent(string,string,string,address,bytes32)' \
  "MNTScout" \
  "Momentum and volume confirmation" \
  "ipfs://credora/mntscout" \
  "$DEPLOYER_ADDRESS" \
  "$STRATEGY_HASH" >/tmp/credora-register-agent.json
echo "REGISTER_AGENT_TX=$(node -e 'const j=require("/tmp/credora-register-agent.json"); console.log(j.transactionHash)')"

send "$SEASON_MANAGER_ADDRESS" \
  'createSeason(string,uint64,uint64,string)' \
  "Mantle AI Alpha Challenge" \
  "$START_TIME" \
  "$END_TIME" \
  "MNT, mETH, USDY" >/tmp/credora-create-season.json
echo "CREATE_SEASON_TX=$(node -e 'const j=require("/tmp/credora-create-season.json"); console.log(j.transactionHash)')"

send "$SEASON_MANAGER_ADDRESS" \
  'joinSeason(uint256,uint256)' \
  1 \
  1 >/tmp/credora-join-season.json
echo "JOIN_SEASON_TX=$(node -e 'const j=require("/tmp/credora-join-season.json"); console.log(j.transactionHash)')"

send "$DECISION_LOGGER_ADDRESS" \
  'submitDecision(uint256,uint256,bytes32,uint8,uint16,uint16,uint64,bytes32,bytes32,string)' \
  1 \
  1 \
  "$MARKET_HASH" \
  0 \
  94 \
  42 \
  14400 \
  "$DATA_HASH" \
  "$RATIONALE_HASH" \
  "ipfs://credora/evidence/mntscout-decision-1" >/tmp/credora-submit-decision.json
echo "SUBMIT_DECISION_TX=$(node -e 'const j=require("/tmp/credora-submit-decision.json"); console.log(j.transactionHash)')"

send "$OUTCOME_REGISTRY_ADDRESS" \
  'submitOutcome(uint256,uint256,uint256,uint8,int256,uint16,bytes32,string)' \
  1 \
  1 \
  1 \
  1 \
  480 \
  94 \
  "$METRICS_HASH" \
  "ipfs://credora/outcomes/mntscout-decision-1" >/tmp/credora-submit-outcome.json
echo "SUBMIT_OUTCOME_TX=$(node -e 'const j=require("/tmp/credora-submit-outcome.json"); console.log(j.transactionHash)')"

send "$REPUTATION_ENGINE_ADDRESS" \
  'submitSeasonScore(uint256,uint256,uint256,uint256,uint256,uint256,int256,uint256,uint256)' \
  1 \
  1 \
  1 \
  1 \
  0 \
  0 \
  480 \
  42 \
  8510 >/tmp/credora-submit-score.json
echo "SUBMIT_SCORE_TX=$(node -e 'const j=require("/tmp/credora-submit-score.json"); console.log(j.transactionHash)')"

send "$REPUTATION_ENGINE_ADDRESS" \
  'submitSeasonRank(uint256,uint256,uint256)' \
  1 \
  1 \
  1 >/tmp/credora-submit-rank.json
echo "SUBMIT_RANK_TX=$(node -e 'const j=require("/tmp/credora-submit-rank.json"); console.log(j.transactionHash)')"

cat > deployment-addresses.env <<EOF
MANTLE_RPC_URL=$RPC_URL
AGENT_PASSPORT_ADDRESS=$AGENT_PASSPORT_ADDRESS
SEASON_MANAGER_ADDRESS=$SEASON_MANAGER_ADDRESS
DECISION_LOGGER_ADDRESS=$DECISION_LOGGER_ADDRESS
OUTCOME_REGISTRY_ADDRESS=$OUTCOME_REGISTRY_ADDRESS
REPUTATION_ENGINE_ADDRESS=$REPUTATION_ENGINE_ADDRESS
MANTLE_EXPLORER_URL=https://explorer.sepolia.mantle.xyz
EOF

echo "Wrote deployment-addresses.env"
