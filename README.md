# ARES PROTOCOL

A treasury system designed to manage and share protocol funds safely.

## What it does

ARES is like a teasure system i designed for a protocol that manages big amount
of funds. It allows governance to propose, approve and carry out treasury action securely.

## My Project Structure

```
src/
  interfaces/
  libraries/
  modules/
  core/
test/
  functional/
  exploits/
script/
```

## Modules 
ProposalSystem - This handles my lodging, committing and cancelling the treasury proposals

 AuthSig        - This verifies that enough guardians has signed a proposal before it moves forward

Timelock       - This holds the proposal in delay queue so it wont be executed immediately

RewardDistributor - This allows contributors to claim thier token rewards uisng the merkle proof

## How to Run it 
cd my folder directory (EVICTION-TEST-DAY-2)

forge install

forge test

## Design Decisions

I thought to add a bond system where proposers stake a small amount of ETH when lodging a proposal. If the proposal is cancelled maliciously they lose the bond. I added this because i felt it would stop people spamming the system with fake proposals
The treasury itself can hold and distribute both ETH and tokens. Contributors claim their token rewards through the RewardDistributor using a merkle proof.

