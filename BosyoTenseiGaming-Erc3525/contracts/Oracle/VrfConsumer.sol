// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract VRFv2Consumer is VRFConsumerBaseV2, ConfirmedOwner {
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId;
    // sepolia
    // bytes32 keyHash =
    //     0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    // polygon Mumbai:
    bytes32 keyHash =
        0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
    uint32 callbackGasLimit = 2000000;
    uint16 requestConfirmations = 12;
    uint32 numWords = 1;
    uint256[] public randomWords;
    constructor(
        uint64 subscriptionId
    )
        //VRFConsumerBaseV2(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625)
        VRFConsumerBaseV2(0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed)
        ConfirmedOwner(msg.sender)
    {
        COORDINATOR = VRFCoordinatorV2Interface(
            0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed 
        );
        s_subscriptionId = subscriptionId;
    }

    function requestRandomWords()
        external
        onlyOwner
        returns (uint256 requestId)
    {
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        _requestId;
        randomWords = _randomWords;
    }
    function getRandomWords() external view returns (uint256[] memory){
        return randomWords;
    }

}
