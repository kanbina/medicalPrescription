pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;



/*
    SPDX-License-Identifier: UNLICENSED
    Assumptions:
    - this represents a single article
    - the contract is deployed ty the seller
    - depoying it suggests it is in stock and available
    ----------
    - Coded for a 'smart user'
    - Basic implementation which assumes only basic data required
    - Prices are in ETH
    - Not tolerant of anomalies; use notes to best of ability
    - Gas price/TX fee not considered; could be better implemented in different chain (see discussion)
*/



contract SupplyChainOfSingleArticle {
    address internal _owner; //initiates owner address variable
    address payable _buyer;
    address payable _seller;
    State _state = State.InStock;

    // would put this into constructor for multiple products
    string _sku = "test-sku";
    uint _price;

    address[] involedIntermediaries;

    event Ordered();
    event Shipped();
    event ReceivdAndPayed();

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner!");
        _;
    }

    enum State {
        InStock,
        Ordered,
        InTransit,
        ReceivedAtBuyer,
        Finished,
        InReturn,
        FinallyReturned,
        OutOfStock
    }

    constructor(uint price) public {
        _owner = msg.sender;
        _seller = msg.sender;
        _price = price;
    }

    function getPrice()  public view returns (uint) {
        return _price;
    }

    function handOverTo(address nextParty) public onlyOwner {
        require (nextParty != _owner, "Cannot hand over to yourself!");
        require (_state == State.Ordered || _state == State.InTransit || _state == State.ReceivedAtBuyer, "Can only hand over on-going shipments!");
        if (nextParty == _buyer) {
            _state = State.ReceivedAtBuyer;
            emit ReceivdAndPayed();
        } else if (_state == State.Ordered) {
            _state = State.InTransit;
            involedIntermediaries.push(nextParty);
            emit Shipped();
        } else if (_state == State.ReceivedAtBuyer) {
            _state = State.InReturn;
            involedIntermediaries.push(nextParty);
        } else if (nextParty == _seller) {
            _state = State.FinallyReturned;
            _seller.transfer(_price);
        } else {
            involedIntermediaries.push(nextParty);
        }
        _owner = nextParty;
    }

    function purchase() public payable {
        require (msg.sender != _seller, "Cannot buy from yourself!");
        require(msg.value >= _price, "Need to pay requested price");
        _buyer = msg.sender;
        _seller.transfer(msg.value);
        _state = State.Ordered;
        emit Ordered();
    }
}