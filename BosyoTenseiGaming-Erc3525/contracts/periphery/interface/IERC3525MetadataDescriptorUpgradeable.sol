// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface IERC3525MetadataDescriptorUpgradeable {

    function constructSlotURI(uint256 slot) external view returns (string memory);
    
    function constructTokenURI(uint256 tokenId) external view returns (string memory);

}