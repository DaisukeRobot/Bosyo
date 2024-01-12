// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.1;

import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/Base64Upgradeable.sol";
import "./interface/IERC3525MetadataDescriptorUpgradeable.sol";
import "../interface_extentions/IERC3525MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ERC3525MetadataDescriptorUpgradeable is Initializable, IERC3525MetadataDescriptorUpgradeable { 

    mapping(uint256 => string) internal _tokenImage;
    function initialize() external initializer{
        _transferOwnership(msg.sender);
    }
    using StringsUpgradeable for uint256;

    function constructSlotURI(uint256 slot_) external view override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    /* solhint-disable */
                    'data:application/json;base64,',
                    Base64Upgradeable.encode(
                        abi.encodePacked(
                            '{"kind":"', 
                            _slotDescription(slot_),
                            '}'
                        )
                    )
                    /* solhint-enable */
                )
            );
    }
    
    function constructTokenURI(uint256 tokenId_) external view override returns (string memory) {
        IERC3525MetadataUpgradeable erc3525 = IERC3525MetadataUpgradeable(msg.sender);
        return 
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64Upgradeable.encode(
                        abi.encodePacked(
                            /* solhint-disable */
                            '{"balance":"',
                            erc3525.balanceOf(tokenId_).toString(),
                            '","slot":"',
                            erc3525.slotOf(tokenId_).toString(),
                            '","image":"',
                            _getTokenImage(tokenId_),
                            "}"
                            /* solhint-enable */
                        )
                    )
                )
            );
    }

    function _baseImageURI() internal view virtual returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    function setTokenImage(uint256 tokenId_,string memory image) external onlyOwner {
        _tokenImage[tokenId_]=image;
    }

    function _getTokenImage(uint256 tokenId_) internal view virtual returns(string memory){
        string memory baseImageURI = _baseImageURI();
        string memory tokenImage = _tokenImage[tokenId_];
        return 
            bytes(baseImageURI).length > 0 ?
            string(abi.encodePacked(baseImageURI,tokenImage)) : ""; 
        
    }
    
    function _slotDescription(uint256 slot_) internal view virtual returns (string memory) {
        if (slot_== 0) {
            return "body";
        }
        if (slot_== 1) {
            return "Hat";
        }
        if (slot_== 2) {
            return "Armor";
        }
        if (slot_== 3) {
            return "weapon";
        }
        return "";
    }
    // ===================================================ownerable Lib========================================
    // copy at OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}