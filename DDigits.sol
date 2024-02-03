// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DDigits is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Pausable,
    Ownable,
    ERC721Burnable
{
    uint256 private _nextTokenId = 1;

    constructor(address initialOwner)
        ERC721("5DDigits", "5D")
        Ownable(initialOwner)
    {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://basedURI/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to) public {
        require(_nextTokenId <= 100000, "No more tokens available to mint.");

        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);

        // Formatear tokenId como un string de 5 dígitos
        string memory tokenIdStr = _formatTokenId(tokenId);

        // Construir la URI del token con el tokenId formateado
        string memory tokenUri = string(
            abi.encodePacked(_baseURI(), tokenIdStr)
        );

        _setTokenURI(tokenId, tokenUri);
    }

    function _formatTokenId(uint256 tokenId)
        internal
        pure
        returns (string memory)
    {
        // Convertir el tokenId en una cadena
        string memory tokenIdStr = Strings.toString(tokenId);

        // Convertir la cadena en bytes para obtener la longitud
        bytes memory tokenIdBytes = bytes(tokenIdStr);

        // Dependiendo de la longitud, agregar los ceros necesarios al principio
        if (tokenIdBytes.length == 1) {
            return string(abi.encodePacked("0000", tokenIdStr));
        } else if (tokenIdBytes.length == 2) {
            return string(abi.encodePacked("000", tokenIdStr));
        } else if (tokenIdBytes.length == 3) {
            return string(abi.encodePacked("00", tokenIdStr));
        } else if (tokenIdBytes.length == 4) {
            return string(abi.encodePacked("0", tokenIdStr));
        } else {
            return tokenIdStr;
        }
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
