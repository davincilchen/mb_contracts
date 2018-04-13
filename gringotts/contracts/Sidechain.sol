pragma solidity ^0.4.15;

import "./SidechainLib.sol";

contract Sidechain {
	address public owner;
	address public sidechainLibAddress;
	uint256 public stageHeight;
	mapping (uint256 => SidechainLib.Stage) private stages;
	mapping (bytes32 => SidechainLib.Log) public logs;
	string public description;

	event ProposeDeposit (
		bytes32 _lightTxHash,
		address _client,
		uint256 _value,
		uint256 _fee,
		uint256 _lsn,
		uint256 _stageHeight,
		uint8 _v,
		bytes32 _r,
		bytes32 _s
	);

	event Deposit (
		uint256 _gsn,
		bytes32 _lightTxHash,
		uint256 _fromBalance,
		uint256 _toBalance
	);

	modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier stageExist (uint256 _stageId) {
    	require(_stageId <= stageHeight);
    	_;
    }

    function Sidechain(address _sidechainOwner, address _sidechainLibAddress) {
    	owner = _sidechainOwner;
    	sidechainLibAddress = _sidechainLibAddress;
    	description = "test";
    	stages[stageHeight].data = "genisis stage";
    }

    function attachStage(
		bytes32 _balanceRootHash,
		bytes32 _receiptRootHash,
		string _data
	) 
		onlyOwner
	{ 
		stageHeight++;
		stages[stageHeight].balanceRootHash = _balanceRootHash;
		stages[stageHeight].receiptRootHash = _receiptRootHash;
		stages[stageHeight].data = _data;
	}

	function proposeDeposit(
		bytes32 _lightTxHash, 
		uint256 _fee,
		uint256 _lsn,
		uint8 _v,
		bytes32 _r,
		bytes32 _s

	) 
		payable 
	{
		logs[_lightTxHash].stageHeight = stageHeight+1;
		logs[_lightTxHash].lsn = _lsn;
		logs[_lightTxHash].client = msg.sender;
		logs[_lightTxHash].value = msg.value;
		logs[_lightTxHash].flagDeposit = false;

		ProposeDeposit ( _lightTxHash, msg.sender, msg.value, _fee, _lsn, stageHeight+1, _v, _r, _s );
	}

	function deposit (
		uint256 _gsn,
		bytes32 _lightTxHash,
		uint256 _fromBalance,
		uint256 _toBalance,
		uint8 _v,
		bytes32 _r,
		bytes32 _s
	) 
		onlyOwner
	{
		SidechainLib lib = SidechainLib(sidechainLibAddress);

		bytes32[] memory bytes32Array = new bytes32[](4);
		bytes32Array[0] = bytes32(_gsn);
		bytes32Array[1] = _lightTxHash;
		bytes32Array[2] = bytes32(_fromBalance);
		bytes32Array[3] = bytes32(_toBalance);

		bytes32 hashMsg = lib.hashArray(bytes32Array);
		address signer = lib.verify(hashMsg, _v, _r, _s);
		if (signer == owner) {
			logs[_lightTxHash].flagDeposit = true;
		}

		Deposit (_gsn, _lightTxHash, _fromBalance, _toBalance);
	}

	function getStageHeight() constant returns (uint256) {
		return stageHeight;
	}
	
	function getStageInfo(uint256 _stageId) stageExist(_stageId) constant returns(bytes32, bytes32, bytes32, string) {
		return 
		(
			stages[_stageId].stageHash,
			stages[_stageId].balanceRootHash,
			stages[_stageId].receiptRootHash,
			stages[_stageId].data
		);
	}
}