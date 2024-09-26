// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MyNFT.sol";

contract MyNFTTest is Test {
    MyNFT nft;
    address user1 = address(0x123);
    address user2 = address(0x456);

    function setUp() public {
        vm.prank(user1);
        nft = new MyNFT("https://localhost/");
    }

    function testMintSuccess() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        nft.mint{value: 0.003 ether}(3);

        assertEq(nft.balanceOf(user1), 3);
        assertEq(nft.totalSupply(), 3);
    }

    function testMintFail_OverMintLimit() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        vm.expectRevert("Minting limit exceeded");
        nft.mint{value: 0.004 ether}(4);
    }

    function testMintFail_OverSupplyLimit() public {
        for (uint256 i = 0; i < 33; i++) {
            address newUser = address(uint160(i + 1));
            vm.deal(newUser, 1 ether);
            vm.prank(newUser);
            nft.mint{value: 0.003 ether}(3);
        }

        vm.prank(user1);
        vm.deal(user1, 1 ether);
        vm.expectRevert("Exceeds max supply");
        nft.mint{value: 0.002 ether}(2);
    }

    function testMintFail_ExceedsMaxTokensPerAddress() public {
        vm.deal(user1, 1 ether);

        vm.prank(user1);
        nft.mint{value: 0.003 ether}(3);

        vm.prank(user1);
        nft.mint{value: 0.003 ether}(3);

        vm.prank(user1);
        vm.expectRevert("Exceeds max tokens per address");
        nft.mint{value: 0.001 ether}(1);
    }

    function testMintFail_InsufficientPayment() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        vm.expectRevert("Insufficient ETH sent");
        nft.mint{value: 0.001 ether}(2);
    }

    function testWithdrawSuccess() public {
        vm.deal(user1, 1 ether);

        vm.prank(user1);
        nft.mint{value: 0.003 ether}(3);

        assertEq(address(nft).balance, 0.003 ether);

        vm.prank(user1);
        nft.withdraw(0.003 ether);

        assertEq(address(nft).balance, 0 ether);
    }

    function testWithdrawFail_NotOwner() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        nft.mint{value: 0.003 ether}(3);

        vm.prank(user2);
        vm.expectRevert();
        nft.withdraw(0.003 ether);
    }

    function testTokenURIReturnsCorrectValue() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        nft.mint{value: 0.001 ether}(1);

        string memory expectedTokenURI = "https://localhost/0.json";
        assertEq(nft.tokenURI(0), expectedTokenURI);
    }
}
