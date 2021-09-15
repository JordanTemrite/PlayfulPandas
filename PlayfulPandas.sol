// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";

contract PlayfulPandas is ERC721Enumerable, Ownable, ERC721Burnable, ERC721Pausable, PaymentSplitter {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdTracker;

    uint256 public constant MAX_ELEMENTS = 10000;
    uint256 public constant PRICE = 6 * (10**16); // (WEI) 0.06 Ether
    uint256 public constant MAX_BY_MINT = 20;
    
    address[] private _team = [
        0x48F0D152D89aB42E4e08bb96E900A1d64cef7f64, // devAddress
        0x596d5B9529d62B44187EeeaF82e728848022F7c8 // promoAddress
        ];
        
    uint256[] private _teamShares = [
        67, // Dev Share
        33 // Promo Share
        ];    

    address payable thisContract;

    string public baseTokenURI;

    event CreatePanda(uint256 indexed id);
    
    constructor()
    ERC721("Playful Pandas", "PANDA") PaymentSplitter(_team, _teamShares)
    {
        setBaseURI('https://api.playfulpandas.io/panda/');
        pause(true);
    }
    
    fallback() external payable {
        
    }

    modifier saleIsOpen {
        require(_totalSupply() <= MAX_ELEMENTS, "Sale end");
        if (_msgSender() != owner()) {
            require(!paused(), "Pausable: paused");
        }
        _;
    }
    
    function setThisContract(address payable _thisContract) external onlyOwner {
        thisContract = _thisContract;
    }

    function _totalSupply() internal view returns (uint) {
        return _tokenIdTracker.current();
    }

    function mint(uint256 _count) public payable saleIsOpen {
        uint256 total = _totalSupply();
        require(thisContract.send(msg.value), "Ether must be sent to this contract");
        require(total.add(_count) <= MAX_ELEMENTS, "Max limit");
        require(total <= MAX_ELEMENTS, "Sale end");
        require(_count <= MAX_BY_MINT, "Exceeds number");
        require(msg.value >= price(_count), "Value below price");

        for (uint256 i = 0; i < _count; i++) {
            uint id = _tokenIdTracker.current().add(1);
            _safeMint(msg.sender, id);
            emit CreatePanda(id);
            _tokenIdTracker.increment();
        }
    }

    function ownerMint(address _to, uint256 _count) public onlyOwner {
        uint256 total = _totalSupply();
        require(total.add(_count) <= MAX_ELEMENTS, "Max limit");
        require(total <= MAX_ELEMENTS, "Sale end");

        for (uint256 i = 0; i < _count; i++) {
            uint id = _tokenIdTracker.current().add(1);
            _safeMint(_to, id);
            emit CreatePanda(id);
            _tokenIdTracker.increment();
        }
    }

    function price(uint256 _count) public pure returns (uint256) {
        return PRICE.mul(_count);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function walletOfOwner(address _owner) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokensId;
    }

    function pause(bool val) public onlyOwner {
        if (val == true) {
            _pause();
            return;
        }
        _unpause();
    }

    function withdrawAll() external onlyOwner {
        for (uint256 i = 0; i < _team.length; i++) {
            address payable wallet = payable(_team[i]);
            release(wallet);
        }
    }
 
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    
}
