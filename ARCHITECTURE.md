# Architecture

## My Summary

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

DRAFT      - When A proposer calls lodgeTransfer, lodgeCall or lodgeUpgrade on the ProposalModule. They must send a certain amount of ETH as a bond. The proposal 
is stored with a unique id and enters the DRAFT stage.

COMMITTED  - This is when Guardians review the proposal and each one calls approve fucntion on the AuthLayer with their signature and a unique nonce. Once enough guardians have signed to meet quorum, governance calls commit fucntion
on the ProposalModule. Then the proposal moves to COMMITTED stage.

QUEUED     -This is After the proposal is committed, governance calls enqueue fucntion on the Timelock. The proposal enters the QUEUED stage and a 
delay clock starts.

EXECUTABLE - The delay has passed and it can now be executed

CLOSED     - The final state, where the proposal is either executed, expired or cancelled. The original proposer can cancel at any stage before CLOSED. If they cancel while still in DRAFT they get their bond back. 
If they cancel after DRAFT they lose their bond as a penalty.


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


