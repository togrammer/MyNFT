// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    uint256 public constant MAX_SUPPLY = 100;
    uint256 public constant MAX_MINT_PER_TX = 3;
    uint256 public constant MAX_TOKENS_PER_ADDRESS = 6;
    uint256 public constant PRICE_PER_TOKEN = 0.001 ether;

    string private baseTokenURI;

    constructor(string memory _baseTokenURI) ERC721("MyNFT", "MNFT") {
        baseTokenURI = _baseTokenURI;
    }

    // Mint function for minting NFTs
    function mint(uint256 _amount) external payable {
        uint256 totalSupply = totalSupply();
        uint256 balance = balanceOf(msg.sender);

        require(_amount > 0 && _amount <= MAX_MINT_PER_TX, "Minting limit exceeded");
        require(totalSupply + _amount <= MAX_SUPPLY, "Exceeds max supply");
        require(balance + _amount <= MAX_TOKENS_PER_ADDRESS, "Exceeds max tokens per address");
        require(msg.value >= PRICE_PER_TOKEN * _amount, "Insufficient ETH sent");

        for (uint256 i = 0; i < _amount; i++) {
            uint256 tokenId = totalSupply + i;
            _safeMint(msg.sender, tokenId);
        }
    }

    // Withdraw function for contract owner to withdraw accumulated ETH
    function withdraw(uint256 _amount) external onlyOwner {
        require(_amount <= address(this).balance, "Not enough funds");
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Withdraw failed");
    }

    // Base URI for metadata
    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    // Update base URI (optional functionality)
    function setBaseURI(string memory _baseTokenURI) external onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    // Fallback function to receive ETH
    receive() external payable {}
}
