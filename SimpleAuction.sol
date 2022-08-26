// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

contract SimpleAuction{
    //Parameters of the simple auction
    address payable public beneficiary;
    uint public auctionEndTime;

    //Current state of the auctionEndTime
    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) public pendingReturns;

    bool ended = false;

    event highestBidIncrease(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(uint _biddingTime, address payable _beneficiary){
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    function bid() public payable{
        if (block.timestamp > auctionEndTime){
            revert("The auction has already ended.");
        }

        if (msg.value <= highestBid){
            revert("There is already a higher or equal bid.");
        }

        if (highestBid != 0){
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        emit highestBidIncrease(msg.sender, msg.value);
    }

    function withdraw() public returns(bool){
        uint amount = pendingReturns[msg.sender];
        if (amount > 0){
            pendingReturns[msg.sender] = 0;

            if(!payable(msg.sender).send(amount)){
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() public{
        if (block.timestamp < auctionEndTime){
            revert("The auction has not ended yet.");
        }

        if (ended){
            revert("The function auctionEnded has already been called.");
        }

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        beneficiary.transfer(highestBid);
    }
}
