# Security Analysis

## My Summary

ARES protocol manages a large amount of treasury funds so security was 
something i took seriously when designing it. Treasury systems 
are always targeted because of the funds so i tried to 
make sure every major attack that has happened to other protocols 
in the past was something i had a defense for in my design.


## Major Attack Surfaces

The biggest attack surfaces in ARES are:

1. The treasury  - it holds a lot of funds so it is the 
   main target for any attacker
2. The proposal system - if someone can lodge and execute a fake 
   proposal they can drain the treasury
3. The signature system - if signatures can be replayed or faked 
   then guardians can be bypassed completely
4. The reward distributor - if merkle proofs can be manipulated 
   anyone can claim tokens they dont deserve
5. Governance address - if the governance address is compromised 
   then the whole system is at risk because it has a lot of power


## Reentrancy

This is when a malicious contract calls back into our 
contract before the first call finishes. This has been used to 
drain funds from real protocols.

I prevented this in two ways. First i  mark proposals as 
executed before making any external call. This just means even if 
someone tries to call back in the proposal is already marked 
done and will be rejected. Second the TimelockModule has a 
locked boolean that blocks any second entry into the discharge 
function while it is already running.


## Signature Replay

Signature replay is when someone takes a valid guardian signature 
and tries to use it again on the same or a different proposal.

I prevent this by giving every signature a nonce. Once a guardian 
uses a nonce it gets marked in the usedNonces mapping and can 
never be used again. I also include the chainId and contract 
address inside every signature so it only works on ARES on this 
specific chain. A signature from another chain or contract will 
not work.


## Double Claim

Double claim is when a contributor tries to claim their reward 
more than once for the same epoch.

I prevent this with a claimed mapping that tracks every address 
that has already claimed for each epoch. Before i process any 
claim i check this mapping first. If they already claimed i 
reject the transaction immediately before any transfer happens.


## Unauthorized Execution

Unauthorized execution is when someone tries to run a proposal 
they are not supposed to be able to run.

I prevent this by making sure every step of the proposal lifecycle 
requires proper authorization. Only governance can commit a 
proposal. Only governance can enqueue it into the timelock. The 
treasury checks that quorum was reached before allowing execution. 
A proposal that skipped any of these steps cannot be executed.


## Timelock Bypass

Timelock bypass is when someone tries to skip the 2 day delay 
and execute a proposal immediately.

I prevent this by storing the exact timestamp when a proposal 
enters the queue. The discharge function checks that the current 
block timestamp is at least 2 days after that stored timestamp. 
This check cannot be skipped or faked. I also added a 48 hour 
execution window after the delay ends so old proposals cannot 
sit in the queue forever and be used as a future attack vector.


## Governance Griefing

Governance griefing is when someone spams the system with fake 
proposals to waste guardian time and slow everything down.

I prevent this with a proposal bond system. Every proposer must 
stake 0.01 ETH when lodging a proposal. If they cancel the 
proposal after it leaves the DRAFT stage they lose that bond as 
a penalty. This makes spamming proposals expensive so an attacker 
would have to spend real money to grief the system.


## Flash Loan Manipulation

Flash loan manipulation is when someone borrows a large amount 
of tokens in one transaction to gain voting power and manipulate 
governance.

In ARES this does not work because guardian status is not based 
on token holdings. Guardians are fixed addresses that are set 
when the contract is deployed. Borrowing tokens does not make 
anyone a guardian so flash loans have no effect on the approval 
process.


## Remaining Risks

I understand that my system might not be correctly implemtented and some risks remain.

If enough guardians are compromised or collude together they 
could approve malicious proposals. The governance address also 
has significant power over the system including the ability to 
commit proposals and set merkle roots. If the governance address 
is ever compromised this would be a serious problem. The merkle 
root for rewards is also set by governance which means a 
malicious governance could set a wrong root and allow bad claims. 
These are risks and more that exist in most governance systems and will
need to be addressed with a more decentralized governance 
structure.