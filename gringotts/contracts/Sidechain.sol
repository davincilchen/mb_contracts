pragma solidity ^0.4.15;

import "./SidechainLib.sol";

contract Sidechain {
	mapping (uint256 => SidechainLib.Stage) public stages;
	mapping (bytes32 => SidechainLib.Log) public logs;
	uint256 public stageHeight;
	address public owner;

	address public sidechainLibAddress;
	string public description;

    event Propose (
        uint256  indexed _type, // {0: deposit, 1: withdrawal}
        bytes32 _lightTxHash,
        bytes32 _client,
        bytes32 _value,
        bytes32 _fee,
        bytes32 _lsn,
        bytes32 _stageHeight,
        bytes32 _v,
        bytes32 _r,
        bytes32 _s
    );

    event VerifyReceipt (
        uint256 indexed _type, // {0: deposit, 1: withdrawal, 2: instantWithdrawal}
        bytes32 _gsn,
        bytes32 _lightTxHash,
        bytes32 _fromBalance,
        bytes32 _toBalance,
        bytes32[3] _sig_receipt,
        bytes32[3] _sig_lightTx
    );

    event AttachStage (
        bytes32 _balanceRootHash,
        bytes32 _receiptRootHash,
        bytes32 _stageHeight
    );

    function Sidechain (address _sidechainOwner, address _sidechainLibAddress) {
        owner = _sidechainOwner;
        sidechainLibAddress = _sidechainLibAddress;
        description = "test";
        stages[stageHeight].data = "genisis stage";
    }

    function delegateToLib (bytes4 _signature, bytes32[] _parameter) payable {
        /*
        'attachStage(bytes32[])':        0x1655e8ac
        'proposeDeposit(bytes32[])':     0xdcf12aba
        'deposit(bytes32[])':            0x7b9d7d74
        'proposeWithdrawal(bytes32[])':  0x68ff1929
        'confirmWithdrawal(bytes32[])':  0xe0671980
        'withdraw(bytes32[])':           0xfe2b3924
        'instantWithdraw(bytes32[])':    0xbe1946da
        */
        sidechainLibAddress.delegatecall( _signature, uint256(32), uint256(_parameter.length), _parameter);
    }
}
