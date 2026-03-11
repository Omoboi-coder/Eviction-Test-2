# Architecture

## Overview

I was asked to design a treasury system for a protocol called ARES from scratch.
The reason they said i had to build it from scratch is because existing treasury designs have 
been exploited before in the ecosystem. Things like governance takeovers and 
replay attacks have happened to real protocols. So instead of copying something 
that already failed i design my own system with security in mind.

The core treasury contract connects all 
four modules together. A proposal starts in ProposalSystem, gets 
approved in AuthSig, waits in Timelock and rewards go through 
RewardDistributor.

The system is split into 4 modules, each one having thier usefulness.


## Why I Split It Into Modules

I did not want to put everything in one contract because if something goes wrong 
in one place it should not affect everything else.

ProposalSystem    - This only handles creating and managing proposals

AuthSig           - This only handles checking if guardians signed something

Timelock          - This one only handles the delay before execution

RewardDistributor - This only handles contributor reward claims


## My Proposal Lifecycle

 My proposal in ARES goes through 5 stages:

DRAFT      - When the proposal was created and waiting for guardian approvals

COMMITTED  - This is when enough guardians has signed it, it is now locked and cannot be changed

QUEUED     - It has entered the timelock, the delay clock starts here

EXECUTABLE - The delay has passed and it can now be executed

CLOSED     - The final state, where the proposal is either executed, expired or cancelled


####  The 5 stages serves different purpose.

DRAFT gives guardians time to review.

COMMITTED locks it so nobody can change it last minute. 

QUEUED starts the delay. EXECUTABLE gives a 48 hour window to run it.

CLOSED makes sure it cannot be used again.


## Security Boundaries

Each module does not trust the others anyhow.

The Timelock only executes proposals that have gone through the proper stages.

The AuthSig module checks signatures and reports back.


## Trust Assumptions

Guardians  - they are trusted to sign or reject proposals honestly

Governance - trusted to start reward epochs and set merkle roots

Contributors - not trusted, they must prove their claim with a merkle proof

Anyone - can execute a proposal once it reaches EXECUTABLE stage


