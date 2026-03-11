// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../Interfaces/IProposalSystem.sol";
import "../Interfaces/IAuthSig.sol";
import "../Interfaces/ITimelock.sol";
import "../Interfaces/IRewardDistributor.sol";
import "../Libraries/Errors.sol";

contract AresTreasury {

    address public governance;

    IProposalSystem public proposalModule;
    IAuthSig public authSig;
    ITimelock public timelock;
    IRewardDistributor public rewardDistributor;

    //The daily drain limit to stop large treasury drains
    uint256 public constant DAILY_DRAIN_LIMIT = 25_000_000 ether;

    uint256 public totalDrainedToday;
    uint256 public lastDrainReset;

    modifier onlyGovernance() {
        if (msg.sender != governance) revert Errors.OnlyGovernance(msg.sender);
        _;
    }

    constructor(
        address _governance,
        address _proposalModule,
        address _authLayer,
        address _timelockEngine,
        address _rewardDistributor
    ) {
        governance        = _governance;
        proposalModule    = IProposalSystem(_proposalModule);
        authSig           = IAuthSig(_authLayer);
        timelock          = ITimelock(_timelockEngine);
        rewardDistributor = IRewardDistributor(_rewardDistributor);
        lastDrainReset    = block.timestamp;
    }

    // this checks quorum was reached before allowing execution
    function execute(
        bytes32 proposalId,
        address target,
        uint256 value,
        bytes calldata callData
    ) external {
        
        if (!authSig.hasQuorum(proposalId)) {
            revert Errors.NotEnoughApprovals(0, 1);
        }

        _checkDrainLimit(value);

        timelock.discharge(proposalId, target, value, callData);
    }

    // this reset drain counter every 24 hours
    function _checkDrainLimit(uint256 amount) internal {
        if (block.timestamp > lastDrainReset + 24 hours) {
            totalDrainedToday = 0;
            lastDrainReset    = block.timestamp;
        }

        if (totalDrainedToday + amount > DAILY_DRAIN_LIMIT) {
            revert Errors.DrainLimitExceeded(totalDrainedToday + amount, DAILY_DRAIN_LIMIT);
        }

        totalDrainedToday += amount;
    }

    receive() external payable {}
}