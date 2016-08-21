contract SupChainContract {
	
	/*
	##This part of code directly makes the transfer/relevant transaction.
	Needed as part of automation is actually a contract that resembles
 	an escrow. It has been done in the next segment of code.##
	
	uint256 public totalSupply;
	
	mapping (address => uint256) public balances;
	
	function SupChainContract(uint256 initialSupply)	{
		balances[msg.sender] = initialSupply;
		totalSupply = initialSupply;
	}
	
	function transfer(address seller, uint256 value)	{
		if (balances[msg.sender] < value)	
			throw;
		if(balances[seller] + value < balances[seller])
			throw;
		balances[msg.sender] -= value;
		balances[seller] += value;
		
	}*/
	
  address buyer;
  address seller;
  address agent;
	
  uint256 public totalSupply;
	
  struct Product	{
	  uint32 productId;
	  uint32 productName;
	  uint256 Quantity;
  }
	
  mapping (address => uint256) public balances;

  Product DoveSoaps;
	
	function quantityDip(uint256 q) returns (uint256)	{
	  if(q < 5)	{
		  //place order to supplier
		  accept(20 * 100); //This means placing an order of 20 new items of price 100
							//each.
		  return 1;		//notifying to frontend that order has been placed
	  }
	  else
		return 0;		//in stock.
  }
	
  function DeliveryStatus(uint256 status)	{
	  if(status == 1)	{		//1 denotes pending
		  //do nothing
	  }
	  if(status == 2)	{		//delivered
		  release(20*100);
	  }
	  if(status == 3)	{		//Order cancelled
	  	  cancel();
	  }
  }
	
  // Each party has an entry here with the timestamp of their acceptance
  uint[3] acceptances;

  bool active;

  function EscrowContract(address _agent, address _seller, uint256 initialSupply) {
    // The person sending money is the buyer and
    // sets up the initial contract
    buyer = msg.sender;
    agent = _agent;
    seller = _seller;
    active = false;
    acceptances[0] = now; // As part of the creation of the contract the buyer accepts
  
	balances[msg.sender] = initialSupply;
	totalSupply = initialSupply;
	balances[agent] = 0;
  }
	
  // This only allows function if contract is active
  modifier onlywhenactive { if (!active) throw; _ }
	
  // This only allows agent to perform function
  modifier onlyagent { if (msg.sender != agent) throw; _ }

  // This only allows parties of the contract to perform function
  modifier onlyparties {
    if ((msg.sender != buyer) && (msg.sender != seller) && (msg.sender != agent))
     throw; _
   }

  // Any party to the contract can accept the contract
  function accept(uint256 value) onlyparties returns(bool) {
    uint party_index;
    // First find the index in the acceptances array
    if (msg.sender == seller)
      party_index = 1;
    else if (msg.sender == agent)
      party_index = 2;

    if (acceptances[party_index] > 0)
      throw;
    else
      acceptances[party_index] = now;

    if (acceptances[0]>0 && acceptances[1]>0 && acceptances[2]>0)	{
      active = true;
	  balances[buyer] -= value;
	  balances[agent] += value;
	}
    return active;
  }

  function release(uint256 value) onlywhenactive onlyagent {
        //suicide(seller); // Send all funds to seller
	    balances[buyer] -= value;
	    balances[seller] += value;
  }

  function cancel() onlyparties	{
    // Any party can cancel the contract before it is active
    if (!active || (msg.sender == agent))	{
      //suicide(buyer); // Cancel escrow and return all funds to buyer
	  balances[buyer] += balances[agent];
	  balances[agent] = 0;
	}
    else
      throw;
  }
}