// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.1;

import "../ERC3525Upgradeable.sol"; 
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../Oracle/VrfConsumer.sol";

contract GameRegistry is Initializable, ERC3525Upgradeable {
    address private _owner;
    uint256 constant Interval = 12 minutes;
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;
    uint256 private _status;

    mapping(uint256 => uint256) internal _allSlotsIndex;
    // slot => tokenId => index
    mapping(uint256 => mapping(uint256 => uint256)) internal _slotTokensIndex;

    struct SlotData {
        uint256 slot;
        uint256[] slotTokens;
    }

    SlotData[] internal _allSlots;



    // =============================================================modifiers=================================================
    modifier notStarted(uint256 kind) {

    }
    modifier isActivate(uint256 kind) {

    }

    function initialize(string memory name_, string memory symbol_, uint8 decimals_,bytes32 OGorEB_root) external initializer {
        __ERC3525_init_unchained(name_, symbol_, decimals_); 
        _initializeSlot();
        _transferOwnership(msg.sender);
       
        _status = NOT_ENTERED;
    }
    function mintBodyToManager(uint256 amount) external onlyOwner nonReentrant{

    }
    
    function _initializeSlot() internal onlyInitializing {
        uint256 allSlotNum = 4;
        for(uint256 i = 0; i < allSlotNum; i++){
            _createSlot(i);
        }
    }
    function addSlot(uint256 slot_) external onlyOwner {
        _createSlot(slot_);
    }

    function startGame(uint256 kind) external onlyOwner notStarted(kind){ 

    }

    function mintProperty(uint256 kind, uint256 amount, address to) public payable nonReentrant isActivate(kind){ 
        
    }

    function setValue(uint startToken,uint endToken, address oracle) external onlyOwner{
        require(balanceOf(startToken) == 0);
        require(startToken < endToken);
        VRFv2Consumer Vrf = VRFv2Consumer(oracle); 
        /**
         * pending
         */
        uint256[] memory randomnums = Vrf.getRandomWords();
        uint256 rnum = randomnums[0]; 
        uint8 randomValue = uint8(rnum % 10) + 1;
        for (uint i = startToken; i <= endToken; i++) {
            ERC3525Upgradeable._mintValue(i, randomValue); 
            randomValue++;
            if (randomValue>10) {
                randomValue = 0;
            }
        }
    }
    // test
    // function setValue(uint startToken,uint endToken) external onlyOwner{
    //     uint256 rnum = 46530278893162991233442269475914785071762639466301882677942890535940207520605; 
    //     uint8 randomValue = uint8(rnum % 10) + 1;
    //     for (uint i = startToken; i <= endToken; i++) {
    //         ERC3525Upgradeable._mintValue(i, randomValue); 
    //         randomValue++;
    //         if (randomValue>10) {
    //             randomValue = 0;
    //         }
    //     }
    // }

    function setMetadataDescriptor(address metadataDescriptor_) external onlyOwner{
        ERC3525Upgradeable._setMetadataDescriptor(metadataDescriptor_);
    }

    function burn(uint256 tokenId_) public {
        require(_isApprovedOrOwner(msg.sender, tokenId_));
        ERC3525Upgradeable._burn(tokenId_);
    }

    function burnValue(uint256 tokenId_, uint256 burnValue_) public {
        require(_isApprovedOrOwner(msg.sender, tokenId_));
        ERC3525Upgradeable._burnValue(tokenId_, burnValue_);
    }

    function transferFrom(
        address from_,
        address to_,
        uint256 tokenId_
    ) public payable override{
        uint256 tokenSlot = ERC3525Upgradeable.slotOf(tokenId_);
        uint256 unlockTime = startTime[tokenSlot] + Interval * 10; 
        require(block.timestamp>unlockTime);
        super.transferFrom(from_,to_,tokenId_); 
    }

    function withdraw() public onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }
    // =====================================================ERC3525Enumerable Lib=====================================

    function _slotExists(uint256 slot_) internal view returns (bool) {
        return _allSlots.length != 0 && _allSlots[_allSlotsIndex[slot_]].slot == slot_;
    }

    function tokenSupplyInSlot(uint256 slot_) public view returns (uint256) {
        if (!_slotExists(slot_)) {
            return 0;
        }
        return _allSlots[_allSlotsIndex[slot_]].slotTokens.length;
    }

    function _createSlot(uint256 slot_) internal {
        require(!_slotExists(slot_));
        SlotData memory slotData = SlotData({
            slot: slot_, 
            slotTokens: new uint256[](0)
        });
        _addSlotToAllSlotsEnumeration(slotData);
       
    }

    
    function _addSlotToAllSlotsEnumeration(SlotData memory slotData) internal {
        _allSlotsIndex[slotData.slot] = _allSlots.length;
        _allSlots.push(slotData);
    }

    function _addTokenToSlotEnumeration(uint256 slot_, uint256 tokenId_) internal {
        SlotData storage slotData = _allSlots[_allSlotsIndex[slot_]];
        _slotTokensIndex[slot_][tokenId_] = slotData.slotTokens.length;
        slotData.slotTokens.push(tokenId_);
    }

   
    // =============================================MerkleProofLib================================================

    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }
    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
    // ============================================ownerable Lib===============================================================

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
        require(owner() == msg.sender);  
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
        require(newOwner != address(0)); 
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
// =====================================ReentrancyGuard LIB===========================================================

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }


// =====================================LIB===================================================================

    function _getTimeGap(uint256 kind) private view returns(uint256){
        
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[36] private __gap;
}