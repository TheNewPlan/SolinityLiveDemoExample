pragma solidity ^0.4.18;

contract vendingmachine{
    address owner;
    function () {
        revert();
    }
    
    function vendingmachine() payable{
        owner = msg.sender;
    }
    
    modifier isOwner(){
        require(msg.sender == owner);
        _;
    }

    event dispenseProduct(bytes32 indexed productName, address indexed buyer, uint price);
    
    struct Product{
        bytes32 name;
        uint256 price;
        uint256 remaining;
    }
    
    mapping (uint256 => Product) products;
    uint256 productIDMAX = 0;
    
    event fundsDeposited(uint value);

    function depositFunds () public payable isOwner {
        fundsDeposited(msg.value);
    }
    
    function withdrawFunds (uint value) public isOwner {
        if(value > this.balance) {
            msg.sender.transfer(value);
        }
    }
    
    event Stocked(uint256 indexed idx, uint256 value);
    function stockProduct(uint256 idx, uint256 value) isOwner public{
        products[idx].remaining += value;
        Stocked(idx, value);
    }
    
    function buyProduct(uint256 idx) public payable returns(bool success){
        Product p = products[idx];
        if(p.remaining == 0){
            revert();
        }
        if(msg.value < p.price){
            revert();
        }
        dispenseProduct(p.name, msg.sender, msg.value);
        return true;
    }
    
    event newProductAdded(bytes32 indexed name, uint price);
    function newProduct(bytes32 _name, uint _price) isOwner public returns(uint idx){
        productIDMAX++;
        products[productIDMAX] = Product({
            name: _name,
            price: _price,
            remaining: 0
        });
        newProductAdded(_name, _price);
    }
    
    function getProduct(uint idx) public returns (bytes32){
        return products[idx].name;
    }
}