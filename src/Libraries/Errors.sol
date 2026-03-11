// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

//  I grouped my Errors by which module they belong to so its easier to trace
//  where an error comes from when debugging

// The following comments on my error codes was written by me to explain what my error does

library Errors {

    // Proposal Errors

    // when someone tries to do something and the proposal doesnt exist
    error ProposalNotFound(bytes32 proposalId);

    // when proposal is in the wrong stage 
    error WrongStage(bytes32 proposalId, uint8 currentStage);

    //  when proposal is in the wrong stage 
    error ProposalExpired(bytes32 proposalId);
    // 
    // when proposer doesnt send enough ETH/token
    error InsufficientBond(uint256 sent, uint256 required);
    
    // when someone who didnt create the proposal tries to cancel it
    error NotProposer(address caller);

    // when a proposal with the same id already exists
    error DuplicateProposal(bytes32 proposalId);

    // Auth Errors

    // when the recovered signer doesnt match expected
    error BadSignature(address recovered, address expected);

    //  when a nonce has already been used
    error NonceAlreadyUsed(address signer, uint256 nonce);

    // when not enough valid signers approved the action
    error NotEnoughApprovals(uint256 got, uint256 need);

    // when an address that is not a guardian tries to sign
    error NotGuardian(address caller);

   
    // The Timelock errors

    // when someone tries to execute before the delay is done
    error TooEarly(uint256 unlockTime, uint256 currentTime);

    // when the execution window has passed
    error ExecutionWindowClosed(bytes32 proposalId);

    //when someone tries to re-enter a function already inside
    error NoReentrancy();


    // Reward errors

    //  when someone tries to claim twice
    error AlreadyClaimed(address claimant);

//  when the merkle proof provided doesnt match the root
    error InvalidProof(address claimant, uint256 amount);

// when there is no active merkle root set yet
    error NoActiveRoot();

   
    // My other Errors

    //  when caller is not the treasury contract
    error OnlyTreasury(address caller);

    //  when caller is not the governance
    error OnlyGovernance(address caller);

    //   when a token transfer fails
    error TransferFailed(address token, address to, uint256 amount);

    //  when trying to drain more than the daily limit allows
    error DrainLimitExceeded(uint256 attempted, uint256 limit);
}