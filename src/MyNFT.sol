// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MyNFT is ERC721, Ownable {
    uint256 public constant TOKEN_PRICE = 0.001 ether;
    uint256 public constant MAX_TOKENS_PER_MINT = 3;
    uint256 public constant MAX_TOKENS_PER_ADDRESS = 6;
    uint256 public constant MAX_TOTAL_SUPPLY = 100;
    string public baseExtension = ".json";

    uint256 private tokenCounter;
    string private baseTokenURI;

    constructor(string memory _baseTokenURI) ERC721("MyNFT", "MNFT") Ownable(msg.sender) {
        baseTokenURI = _baseTokenURI;
        tokenCounter = 0;
    }

    function mint(uint256 quantity) external payable {
        require(quantity > 0 && quantity <= MAX_TOKENS_PER_MINT, "Minting limit exceeded");
        require(msg.value >= quantity * TOKEN_PRICE, "Insufficient ETH sent");
        require(balanceOf(msg.sender) + quantity <= MAX_TOKENS_PER_ADDRESS, "Exceeds max tokens per address");
        require(tokenCounter + quantity <= MAX_TOTAL_SUPPLY, "Exceeds max supply");

        for (uint256 i = 0; i < quantity; i++) {
            _safeMint(msg.sender, tokenCounter);

            tokenCounter++;
        }
    }

    function totalSupply() public view returns (uint256) {
        return tokenCounter;
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(owner()).transfer(amount);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(ownerOf(tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");
        return string.concat(baseTokenURI, Strings.toString(tokenId), baseExtension);
    }
}