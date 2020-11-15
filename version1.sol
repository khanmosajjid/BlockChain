pragma solidity >=0.5.11;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}

contract Quantum {
    using SafeMath for uint256;

    uint256 public constant ENTRY_AMOUNT = 0.13 ether;

    uint256[] public basketPrice;

    uint256 public totalUsers;
    
    uint256 public extraEarning;

    uint256 public adminWallet;
    //owner
    address owner;
    struct User {
        uint256 id;
        uint256[] referralArray;
        address upline;
        uint256 basketsPurchased;
        uint256 totalEarning;
        uint256 myWallet;
        
        bool isExist;
    }

    mapping(address => User) public users;
    mapping(uint256 => address) public usersId;
    event RegisterEvent(address _add);

    //constructor
    constructor() public payable {
        //make deployer as owner (msg.sender)
        owner = msg.sender;
        require(msg.value >= ENTRY_AMOUNT, "insufficient amount");
        adminWallet = adminWallet.add(0.03 ether);
        users[msg.sender].myWallet = users[msg.sender].myWallet.add(0.05 ether);

        basketPrice.push(0.05 ether);
        basketPrice.push(0.1 ether);
        basketPrice.push(0.2 ether);
        basketPrice.push(0.4 ether);
        basketPrice.push(0.8 ether);
        basketPrice.push(1.6 ether);
        basketPrice.push(3.2 ether);
        basketPrice.push(6.4 ether);
        basketPrice.push(12.8 ether);
        basketPrice.push(25.6 ether);
        basketPrice.push(51.2 ether);
        basketPrice.push(102.4 ether);
        basketPrice.push(204.8 ether);

        totalUsers = 1;

        users[msg.sender].id = totalUsers;

        users[msg.sender].isExist = true;
       

        //make msg.sender as first user
        users[msg.sender].upline = address(0);

        autoBuyBasket();
        amountDistribute();

        usersId[totalUsers] = msg.sender;
    }

    //function to register user
    function Register(address _upline) public payable {
        //check if amount>=0.13 ether
        require(msg.value >= ENTRY_AMOUNT, "less amount");

        //user should not exist already
        require(users[msg.sender].isExist == false, "user already exist");

        require(users[_upline].isExist == true, "upline not exist");

        //msg.sender
        totalUsers++;

        users[msg.sender].id = totalUsers;

        //upline
        users[msg.sender].upline = _upline;
        users[msg.sender].isExist = true;

        adminWallet = adminWallet.add(0.03 ether);
        users[msg.sender].myWallet = users[msg.sender].myWallet.add(0.05 ether);

        usersId[totalUsers] = msg.sender;
        users[_upline].referralArray.push(totalUsers);
        uint256 size=users[_upline].referralArray.length;
        if(size%4!=0){
             amountDistribute();
        }
        else if(size%4==0){
            address ref=users[msg.sender].upline;
            ref=users[ref].upline;
            users[ref].totalEarning=users[ref].totalEarning.add(0.05 ether);
        }
        autoBuyBasket();
        emit RegisterEvent(msg.sender);
    }
    
    
    
    function amountDistribute() public{
         address ref=users[msg.sender].upline;
        for(uint256 i=0;i<4;i++){
        //      if(msg.sender==owner){
        //      extraEarning=extraEarning.add(0.05 ether) ;
        //      break;
        //   }
             if(ref==address(0)){
                if(i==0){
                    extraEarning=extraEarning.add(0.025 ether) ;
                   
                    
                    
                }
               else if(i==1){
                   extraEarning=extraEarning.add(0.0125 ether) ;
                  
                    
                    
                }
                else if(i==2){
                    extraEarning=extraEarning.add(0.0075 ether) ;

                    
                }                    
               else if(i==3){
                   extraEarning=extraEarning.add(0.005 ether) ;
                  
               }
                
            }
            else{
                
                if(i==0){
                    users[ref].totalEarning=users[ref].totalEarning.add(0.025 ether);
                    
                    
                }
               else if(i==1){
                   users[ref].totalEarning=users[ref].totalEarning.add(0.0125 ether);
                  
                    
                    
                }
                else if(i==2){
                    users[ref].totalEarning=users[ref].totalEarning.add(0.0075 ether);
                   
                    
                    
                }
               else if(i==3){
                   users[ref].totalEarning=users[ref].totalEarning.add(0.005 ether);
                   users[ref].totalEarning+=0.005 ether;
                   
                   
               }
                
            }
            ref=users[ref].upline;
            
        }
    }
        
    

    function buyBasket(uint256 _basketNumber) public payable {
        require(
            _basketNumber > users[msg.sender].basketsPurchased &&
                _basketNumber <= 13,
            "basket already purchased"
        );

        require(
            msg.value >= basketPrice[_basketNumber - 1],
            "you should have enough balance"
        );
        users[msg.sender].basketsPurchased = users[msg.sender]
            .basketsPurchased
            .add(1);
    }

    function autoBuyBasket() public {
        if (users[msg.sender].basketsPurchased < 13) {
            if (
                users[msg.sender].myWallet >=
                basketPrice[users[msg.sender].basketsPurchased]
            ) {
                users[msg.sender].myWallet = users[msg.sender].myWallet.sub(
                    basketPrice[users[msg.sender].basketsPurchased]
                );
                users[msg.sender].basketsPurchased = users[msg.sender]
                    .basketsPurchased
                    .add(1);
            }
        }
    }
    
    function getSize() public view returns(uint256 ){
        return users[msg.sender].referralArray.length;
    }
}