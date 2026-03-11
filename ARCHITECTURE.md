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

## My Libraries

I also built three libraries that the modules connect to.

ProposalLib holds the proposal struct and the stage logic. 
I put it in a library so the module is clean.

SignatureLib handles checking who signed a message. It includes 
the chainId so signatures cannot be reused on other chains.

MerkleLib handles checking merkle proofs for the reward system.


## How Everything Connects

So when a proposer wants to move funds they will lodge a proposal in 
ProposalModule and the Guardians will sign it in the AuthSig. The Governance commits 
and queues it and after the delay anyone can execute it through the
AresTreasury which connects to the Timelock.

The RewardDistributor is separate. The Contributors can claim 
their rewards independently anytime they want.


## My Proposal Lifecycle

 My proposal in ARES goes through 5 stages:

DRAFT      - When A proposer calls lodgeTransfer, lodgeCall or lodgeUpgrade on the ProposalModule. They must send a certain amount of ETH as a bond. The proposal 
is stored with a unique id and enters the DRAFT stage.

COMMITTED  - This is when Guardians review the proposal and each one calls approve fucntion on the AuthLayer with their signature and a unique nonce. Once enough guardians have signed to meet quorum, governance calls commit fucntion
on the ProposalModule. Then the proposal moves to COMMITTED stage.

QUEUED     -This is After the proposal is committed, governance calls enqueue fucntion on the Timelock. The proposal enters the QUEUED stage and a 
delay clock starts.

EXECUTABLE - The delay has passed here and Anyone can now call execute 
on the AresTreasury. There is a 48 hour window to this, 
after that the proposal expires.

CLOSED     - The final state, where the proposal is either executed, expired or cancelled. The original proposer can cancel at any stage before CLOSED. If they cancel while still in DRAFT they get their bond back. 
If they cancel after DRAFT they lose their bond as a penalty.


The 5 stages serves different purpose.

DRAFT gives guardians time to review.

COMMITTED locks it so nobody can change it last minute. 

QUEUED starts the delay. EXECUTABLE gives a 48 hour window to run it.

CLOSED makes sure it cannot be used again.


## Security Boundaries

Each module does not trust the others anyhow or blindly.

ProposalModule only create proposals, it does not execute at all

The AuthSig module checks signatures and dosent have access to funds.

The Timelock only executes proposals that have gone through the proper stages.

RewardDistributor rejects claim without any valid proof.




## Trust Assumptions

Guardians  - Guardians are trusted to sign or reject proposals 
honestly. If they collude with a bad proposer the system can 
be manipulated which is a big  risk

Governance - They are trusted to start reward epochs and set 
merkle roots. Governance has a lot of power in this system so 
if that address is compromised it is a serious problem.

Contributors - The contributors are not trusted at all, they must always prove their claim with a merkle proof. I did this because anyone 
could lie about being a contributor.

Anyone - Anyone Can execute a proposal once it reaches the executable stage. I made it this way on purpose so if one person goes offline it does not affect the whole system.


