pragma solidity ^0.8.1;

import "./libs/Ownable.sol";
import "./interfaces/IERC721Enumerable.sol";
import "hardhat/console.sol";

contract MetadataStore is Ownable {
    // Public variables

    bytes32[] public ipfsHashes;
    address private _nftaddress;
    string private BASE_URI = "https://ipfs.infura.io/ipfs/";
    bytes2 private CONSTANT = 0x1220;

    // Internal variables
    bytes internal constant _ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";

    constructor(address nftAddress) {
        _nftaddress = nftAddress;
    }

    /*
    Store Metadata comprising of IPFS Hashes (In Hexadecimal minus the first two fixed bytes) and explicit traits
    Ordered according to original hashed sequence pertaining to the Hashmasks provenance
    Ownership is intended to be burned (Renounced) after storage is completed
    */
   // bytes32 is already an array of fixed lengh
    function storeMetadata(bytes32[] memory ipfsHashInHex, uint256 startIndex, uint256 qty)
        public
        onlyOwner
    {
        require(IERC721Enumerable(_nftaddress).totalSupply() >= (startIndex + qty), "Token Not yet Minted");
        
        for(uint256 temp = startIndex; temp < (startIndex + qty); temp++) {
                ipfsHashes[temp] = ipfsHashInHex[temp - startIndex]; 
        }
    }

    function getTokenURI(uint256 tokenIndex)
        public
        view
        returns (string memory result) 
    {
        require(tokenIndex < ipfsHashes.length, "MetaData Does Not Exist");
        //Hex to Base58
        bytes memory temp = abi.encodePacked(CONSTANT,  ipfsHashes[tokenIndex]);
        result = string(abi.encodePacked(BASE_URI, _toBase58(temp)));
        console.log(result);
       // return abi.encodePacked(BASE_URI, ipfsHashes[tokenIndex]);
    }
    
       // Source: verifyIPFS (https://github.com/MrChico/verifyIPFS/blob/master/contracts/verifyIPFS.sol)
    // @author Martin Lundfall (martin.lundfall@consensys.net)
    // @dev Converts hex string to base 58
    function _toBase58(bytes memory source)
        internal
        pure
        returns (string memory)
    {
        if (source.length == 0) return new string(0);
        uint8[] memory digits = new uint8[](46);
        digits[0] = 0;
        uint8 digitlength = 1;
        for (uint256 i = 0; i < source.length; ++i) {
            uint256 carry = uint8(source[i]);
            for (uint256 j = 0; j < digitlength; ++j) {
                carry += uint256(digits[j]) * 256;
                digits[j] = uint8(carry % 58);
                carry = carry / 58;
            }

            while (carry > 0) {
                digits[digitlength] = uint8(carry % 58);
                digitlength++;
                carry = carry / 58;
            }
        }
        return string(_toAlphabet(_reverse(_truncate(digits, digitlength))));
    }

    function _truncate(uint8[] memory array, uint8 length)
        internal
        pure
        returns (uint8[] memory)
    {
        uint8[] memory output = new uint8[](length);
        for (uint256 i = 0; i < length; i++) {
            output[i] = array[i];
        }
        return output;
    }

    function _reverse(uint8[] memory input)
        internal
        pure
        returns (uint8[] memory)
    {
        uint8[] memory output = new uint8[](input.length);
        for (uint256 i = 0; i < input.length; i++) {
            output[i] = input[input.length - 1 - i];
        }
        return output;
    }

    function _toAlphabet(uint8[] memory indices)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory output = new bytes(indices.length);
        for (uint256 i = 0; i < indices.length; i++) {
            output[i] = _ALPHABET[indices[i]];
        }
        return output;
    }

}