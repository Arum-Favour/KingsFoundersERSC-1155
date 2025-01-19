// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Pausable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

contract KingsFounders is ERC1155, Ownable, ERC1155Pausable, ERC1155Supply, PaymentSplitter {
    uint256 public publicPrice = 0.02 ether;
    uint256 public allowListPrice = 0.01 ether;
    uint256 public maxSupply = 1;
    uint public maxPerWallet = 3;

    bool public publicMintOpen = false;
    bool public allowListMintOpen = true;

    mapping (address => bool) allowList;
    mapping (address => uint256) purchasesPerWallet;

    constructor(address initialOwner, address[] memory _payees, uint256[] memory _shares)
        ERC1155("ipfs://QmY5rPqGTN1rZxMQg2ApiSZc7JiBNs1ryDzXPZpQhC1ibm/")
        Ownable(initialOwner)
        PaymentSplitter(_payees, _shares)
    {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function editMintWindows(bool _publicMintOpen, bool _allowListMintOpen) external onlyOwner{
             publicMintOpen = _publicMintOpen  ;
              allowListMintOpen  =  _allowListMintOpen;
    }

    function setAllowList(address[] calldata addresses) external onlyOwner{
        for(uint256 i = 0; i < addresses.length; i++){
            allowList[addresses[i]] = true;
        }
    }

    function allowListMint(uint256 id, uint256 amount) public payable {
        require(allowListMintOpen, "AllowList not yet Open!");
        require(allowList[msg.sender], "You're not in the allowList");
        require(msg.value == allowListPrice * amount, "INSUFFICIENT funds!");
        require(
            totalSupply(id) + amount <= maxSupply,
            "SORRY! we have minted out"
        );
        require(
            id < 2,
            "sorry looks like you're trying to mint the wrong nft!"
        );
        _mint(msg.sender, id, amount, "");
    }

    function publicMint(uint256 id, uint256 amount) public payable {
        require(publicMintOpen, "Public Mint is closed");
        require(purchasesPerWallet[msg.sender] + amount <= maxPerWallet, "Max mint for wallet reached");
        require(
            id < 2,
            "sorry looks like you're trying to mint the wrong nft!"
        );
        require(
            msg.value == publicPrice * amount,
            "WRONG! not enough money sent"
        );
        require(
            totalSupply(id) + amount <= maxSupply,
            "SORRY! we have minted out"
        );
        purchasesPerWallet[msg.sender] += amount;
        _mint(msg.sender, id, amount, "");
    }

    function withdraw(address _addr) external onlyOwner{
        uint balance = address(this).balance;
        payable(_addr).transfer(balance);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Pausable, ERC1155Supply) {
        super._update(from, to, ids, values);
    }
}
