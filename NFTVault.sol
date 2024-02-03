// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTVault {
    mapping(uint256 => address) private originalOwners;
    // Mapping para propietarios de fracciones: tokenId => serie => fraccion => propietario
    mapping(uint256 => mapping(uint256 => mapping(uint256 => address)))
        private fraccionOwners;

    IERC721 public nftContract;
    IERC20 public lottoContract;

    uint256 constant MAXDECIMOSPORNUM = 1850;
    uint256 constant FRACCIONES_POR_SERIE = 10;
    //uint256 constant TOTALDECIMOS = 185000000;

    event DepositedNFT(uint256 tokenId, address owner);
    event FraccionComprada(
        uint256 tokenId,
        uint256 serie,
        uint256 fraccion,
        address comprador
    );

    constructor(address _nftContract, address _lottoContract) {
        nftContract = IERC721(_nftContract);
        lottoContract = IERC20(_lottoContract);
    }
    
    // Modificador para verificar si el llamante es el propietario original
    modifier onlyOriginalOwner(uint256 tokenId) {
        require(
            msg.sender == originalOwners[tokenId],
            "No eres el propietario original."
        );
        _;
    }

    function depositNFT(uint256 tokenId) public {
        // Comprobar que el depositario es el dueño de ese tokenId
        require(nftContract.ownerOf(tokenId) == msg.sender);
        // Transferir el dueño a nuestro mapping de originalOwners
        originalOwners[tokenId] = msg.sender;
        // Transferir el erc721 a este contrato.
        nftContract.transferFrom(msg.sender, address(this), tokenId);
        // Registrar el propietario de la primera fracción (serie 1, fracción 1)
        fraccionOwners[tokenId][1][1] = msg.sender;
        // Envía 1 token LOTTO de este contrato al msg.sender como recompensa
        lottoContract.transfer(msg.sender, 1 * 10**18);

        emit DepositedNFT(tokenId, msg.sender);
    }

    function comprarFraccion(uint256 tokenId, uint256 serie) public {
        require(
            serie > 0 && serie <= (MAXDECIMOSPORNUM / FRACCIONES_POR_SERIE),
            "Serie invalida."
        );
        // Encuentra la próxima fracción disponible en la serie
        uint256 fraccionDisponible = 0;
        for (uint256 i = 1; i <= FRACCIONES_POR_SERIE; i++) {
            if (fraccionOwners[tokenId][serie][i] == address(0)) {
                fraccionDisponible = i;
                break;
            }
        }

        // Verifica que haya una fracción disponible
        require(
            fraccionDisponible > 0,
            "No hay fracciones disponibles en esta serie."
        );
        // Registrar al comprador de la fracción disponible
        fraccionOwners[tokenId][serie][fraccionDisponible] = msg.sender;
        // Envía 1 token LOTTO de este contrato al msg.sender como pago por la fracción
        lottoContract.transfer(msg.sender, 1 * 10**18);

        emit FraccionComprada(tokenId, serie, fraccionDisponible, msg.sender);
    }

    function consultarPropietarioFraccion(
        uint256 tokenId,
        uint256 serie,
        uint256 fraccion
    ) public view returns (address) {
        require(
            serie > 0 && serie <= (MAXDECIMOSPORNUM / FRACCIONES_POR_SERIE),
            "Serie invalida."
        );
        require(
            fraccion > 0 && fraccion <= FRACCIONES_POR_SERIE,
            "Fraccion invalida."
        );
        address owner = fraccionOwners[tokenId][serie][fraccion];
        require(
            owner != address(0),
            "La fraccion no tiene propietario o no existe."
        );
        return owner;
    }

    function fraccionExiste(
        uint256 tokenId,
        uint256 serie,
        uint256 fraccion
    ) public view returns (bool) {
        require(
            serie > 0 && serie <= (MAXDECIMOSPORNUM / FRACCIONES_POR_SERIE),
            "Serie invalida."
        );
        require(
            fraccion > 0 && fraccion <= FRACCIONES_POR_SERIE,
            "Fraccion invalida."
        );
        return fraccionOwners[tokenId][serie][fraccion] != address(0);
    }

    function withdrawNFT(uint256 tokenId) public onlyOriginalOwner(tokenId) {
        require(
            msg.sender == originalOwners[tokenId],
            "No eres el propietario original."
        );
        nftContract.transferFrom(address(this), msg.sender, tokenId);
        delete originalOwners[tokenId];
    }
}
