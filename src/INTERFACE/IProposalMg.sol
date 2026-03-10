// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IProposalMg {

    enum Proposal {
        Transfer,
        Call,
        Upgrade
    }

    enum Lifecycle {
        Drafting,
        Committed,
        TimeLocked,
        Executed,
        Cancelled
    }

    struct TreasuryProposal {
          uint256 proposalId;
        address proposerAddress;
        Proposal proposalType;
        address targetContractAddress; 
        uint256 targetEthValue;    
        bytes actionPayloadData;          
        address outputTokenAddress;       
        uint256 outputTokenAmount;      
        address recipientAddress;      
        Lifecycle currentStage;
        uint256 signatureCount;
    }

    event ProposalLodged(uint256 indexed proposalId, address indexed creatorAddress);

    event ProposalCommitted(uint256 indexed proposalId);

    function lodgeTransfer(address creatorAddress, address tokenAddress, address recipientAddress, uint256 transferAmount) external returns (uint256);
    function lodgeCall(address creatorAddress, address targetAddress, uint256 callValue, bytes calldata callData) external returns (uint256);
    function lodgeUpgrade(address creatorAddress, address targetAddress, bytes calldata callData) external returns (uint256);
    
    //fucntion state
    function explicitlyCommit(uint256 proposalId, address callerAddress) external;
    function recordSignerVote(uint256 proposalId, address signerAddress) external;
    function moveToTimelock(uint256 proposalId) external;
    function markAsDischarged(uint256 proposalId) external;
    function getProposalDetails(uint256 proposalId) external view returns (TreasuryProposal memory);
}