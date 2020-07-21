pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

/*
    SPDX-License-Identifier: UNLICENSED
    Assumptions:
    - Coded for a 'smart user'
    - Basic implementation which assumes only basic data required
    - Prices are in ETH
    - Not tolerant of anomalies; use notes to best of ability
    - Gas price/TX fee not considered; could be better implemented in different chain (see discussion)
*/

contract SupplyChain
{
    uint sku; //initiate SKU variable

    mapping(uint => Order) private totalOrder; //mapping SKUs to orders

    address internal owner; //initiates owner address variable

    State initState = State.Created; //standard initial state is Created

    enum State //possible states of order
    {
        Created,
        Producer,
        toDistributor,
        Distributor,
        toRetailer,
        Retailer
    }

    struct Order { //information recorded in an order
        uint sku;
        uint quantity;
        uint unitPrice;
        uint totalValue;
        string itemDescription;
        string producerName;
        string distributorName;
        string retailerName;
        address producerAdd;
        address distributorAdd;
        address retailerAdd;
        State orderState;
    }

    //events for logging
    event orderPlaced(uint sku);
    event paid(uint sku, address sender, address receiver);
    event produced(uint sku);
    event Distributor(uint sku);
    event Retailer(uint sku);
    event sold(uint sku);

    modifier onlyOwner() //permissioned to owner only
    {
        require(msg.sender == owner, "You must be the owner.");
        _;
    }

    modifier verifyPurchase(uint _money) //verifies that amount paid is amount required
    {
        require(msg.value == _money, "That was not the correct amount.");
        _;
    }

    /*
        Modifiers which require the order to be at a certain state
    */
    modifier atProducer(uint _sku)
    {
        require(totalOrder[_sku].orderState == State.Producer, "Order must be at producer.");
        _;
    }

    modifier onRouteDistributor(uint _sku)
    {
        require(totalOrder[_sku].orderState == State.toDistributor, "Order must be on route to distributor.");
        _;
    }

    modifier atDistributor(uint _sku)
    {
        require(totalOrder[_sku].orderState == State.Distributor, "Order must be at distributor.");
        _;
    }

    modifier onRouteRetailer(uint _sku)
    {
        require(totalOrder[_sku].orderState == State.toRetailer, "Order must be on route to retailer.");
        _;
    }

    modifier atRetailer(uint _sku)
    {
        require(totalOrder[_sku].orderState == State.toRetailer, "Order must be at Retailer.");
        _;
    }

    constructor() public //initiate owner as contract deployer, and sku as 1
    {
        owner = msg.sender;
        sku = 1;
    }

    function abort() public onlyOwner() //abort contract
    {
        address payable ownerAbort = makePayable(owner);
        selfdestruct(ownerAbort);
    }

    function makePayable(address a) public pure returns (address payable) //change address to address payable
    {
        return address(uint160(a));
    }

    function changeOwner(address newOwner) public onlyOwner() //transfer ownership of contract
    {
        owner = newOwner;
    }

    function createOrder(uint _quantity, uint _unitPrice, string memory _description,
    string memory _producer, string memory _distributor, string memory _retailer) public onlyOwner() //create a new order
    {
        address _producerAdd;
        address _distributorAdd;
        address _retailorAdd;
        Order memory order;
        order.sku = sku;
        order.quantity = _quantity;
        order.unitPrice = _unitPrice;
        order.totalValue = _quantity * _unitPrice;
        order.itemDescription = _description;
        order.producerName = _producer;
        order.distributorName = _distributor;
        order.retailerName = _retailer;
        order.orderState = initState;
        order.producerAdd = _producerAdd;
        order.distributorAdd = _distributorAdd;
        order.retailerAdd = _retailorAdd;
        sku++; //update sku count
        changeOwner(_producerAdd);
        emit orderPlaced(sku);
    }

    function pay(uint _sku, State _state, uint _payment) public payable onlyOwner verifyPurchase(_payment)
    //pay between parties depending on what stage order is on
    {
        address temp;
        if(_state == State.Producer) {temp = totalOrder[_sku].producerAdd;}
        if(_state == State.Distributor) {temp = totalOrder[_sku].distributorAdd;}
        if(temp != address(0))
        {
            address payable receiver = makePayable(temp);
            receiver.transfer(_payment);
            emit paid(_sku, msg.sender, temp);
        }
        else
        {
            abort();
        }
    }

    /*
        Functions to transition through pipeline
    */
    function orderProduced(uint _sku) public
    {
        totalOrder[_sku].orderState = State.Producer;
    }

    function ProducerSent(uint _sku) public atProducer(_sku)
    {
        totalOrder[_sku].orderState = State.toDistributor;
    }

    function receivedDistributor(uint _sku) public onRouteDistributor(_sku)
    {
        totalOrder[_sku].orderState = State.Distributor;
        changeOwner(totalOrder[_sku].distributorAdd);
    }

    function DistributorSent(uint _sku) public atDistributor(_sku)
    {
        totalOrder[_sku].orderState = State.toRetailer;
    }

    function receivedRetailer(uint _sku) public onRouteRetailer(_sku)
    {
        totalOrder[_sku].orderState = State.Retailer;
        changeOwner(totalOrder[_sku].retailerAdd);
    }
}