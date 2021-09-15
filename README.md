# PlayfulPandas

CHANGE LOG - PLAYFUL PANDAS

Added SPDX License to top of file - Set to MIT (Change this as you see fit, MIT is standard)


CHANGES ----> 
	
	pragma solidity ^0.8.0; To ---->
	pragma solidity 0.8.7; (It is best practice to define the specific compiler version to be used)

	uint256 public constant PRICE = 6 * 10**16; // (WEI) 0.06 Ether to --->
	uint256 public constant PRICE = 6 * (10**16); // (WEI) 0.06 Ether (Not required but good practice)

	require(total + _count <= MAX_ELEMENTS, "Max limit"); to ---> (Changed this in mint() and ownerMint());
	require(total.add(_count) <= MAX_ELEMENTS, "Max limit"); (Utilizes safemath now)


QUESTION ---->

	Why do you have both of these functions? 

    	function _totalSupply() internal view returns (uint) {
        	return _tokenIdTracker.current();
    	}

    	function totalMint() public view returns (uint256) {
        	return _totalSupply();
    	}

	(In later edits I have removed totalMint())

ADDITIONS ---->

	Since you plan to recieve ether in this contract, added fallback function --->

	fallback() external payable {
        
    	}

	Added ---->

	address payable thisContract;

	function setThisContract(address payable _thisContract) external onlyOwner {
        	thisContract = _thisContract;
    	}

	require(thisContract.send(msg.value), "Ether must be sent to this contract"); --> Requires that the value of the message is sent to the contract
	(This prevents someone from manipulating the JS that sends the call to another address resulting in loss of funds for the project)


CHANGES ---->


	Added PaymentSplitter.sol to imports

	Replaced address declarations for dev and promo to this --->

	address[] private _team = [
        0x48F0D152D89aB42E4e08bb96E900A1d64cef7f64, // devAddress
        0x596d5B9529d62B44187EeeaF82e728848022F7c8 // promoAddress
        ];


	Replaced withdrawAll() with this ---->

	function withdrawAll() external onlyOwner {
        	for (uint256 i = 0; i < _team.length; i++) {
            		address payable wallet = payable(_team[i]);
            		release(wallet);
        	}
    	}
	

	Removed withdraw() ---> (No longer needed when using payment splitter. There is an inherited "release" function for individual withdrawl now)


	Removed address _to from mint() ---> Replaced with msg.sender() (You can keep _to if you want people to mint other people NFTs)


	Changed ----> (IN MINT())

	for (uint256 i = 0; i < _count; i++) {
            _mintAnElement(_to);
        }

	To --->

	for (uint256 i = 0; i < _count; i++) {
            uint id = _tokenIdTracker.current().add(1);
            _safeMint(msg.sender, id);
	    emit CreatePanda(id);
            _tokenIdTracker.increment();
        }


	Changed ----> (IN OWNERMINT()) ---> (I kept the _to here since you may want to mint elements to another address as the owner)

	for (uint256 i = 0; i < _count; i++) {
            _mintAnElement(_to);
        }

	To ----> 

	for (uint256 i = 0; i < _count; i++) {
            uint id = _tokenIdTracker.current().add(1);
            _safeMint(_to, id);
            emit CreatePanda(id);
            _tokenIdTracker.increment();
        }

	Removed totalMint() ----> Not required
