// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0 <0.9.0;
// pragma solidity ^0.5.0;

contract Verification {
    
    // admin variable to store the address of the admin
    address admin;
    
    //  Struct customer
    //  uname - username of the customer
    //  dataHash - customer data
    //  rating - rating given to customer given based on regularity
    //  upvotes - number of upvotes recieved from organization
    //  org - address of org that validated the customer account

    struct Customer {
        string uname;
        string dataHash;
        uint rating;
        uint upvotes;
        address org;
        string password;
    }

    //  Struct Bank/Organisation
    //  name - name of the bank/organisation
    //  ethAddress - ethereum address of the bank/organisation
    //  rating - rating based on number of valid/invalid verified accounts
    //  KYC_count - number of KYCs verified by the bank/organisation
    struct Organisation {
        string name;
        address ethAddress;
        uint rating;
        uint KYC_count;
        string regNumber;
    }
    
    // Struct KYC_Request
    // uname - Username will be used to map the KYC request with the customer data. 
    // bankAddress - Bank address here is a unique account address for the bank, which can be used to track the bank.
    // dataHash - hash of the data or identification documents provided by the Customer.
    // isAllowed - request is added by a trusted organization or not.
    struct KYC_Request {
        string uname;
        address orgAddress;
        string dataHash;
        bool isAllowed;
    }
    
    //  Struct finalCustomer
    //  uname - username of the customer
    //  dataHash - customer data
    //  rating - rating given to customer given based on regularity
    //  upvotes - number of upvotes recieved from organizations
    //  org - address of organization that validated the customer account
    struct VerifiedCustomer {
        string uname;
        string dataHash;
        uint rating;
        uint upvotes;
        address org;
        string password;
    }
    
    //  List of all customers
    Customer[] allCustomers;

    //  List of all Banks/Organisations
    Organisation[] allOrgs;

    
    // List of all KYC_Request
    KYC_Request[] allRequests;
    
    // List of all finalCustomers
    VerifiedCustomer[] allVerifiedCustomers;
    
    
    //Setting the admin as the person who deploys the smart contract onto the network.
    constructor() {
        admin = msg.sender;
    }
    
    function addOrg(string memory bankName, address bankAddress, string memory bankRegistrationNumber) public payable returns(bool) {
        bool isAddedToOrgListFlag = false;
        
        //verify if the user trying to call this function is admin or not.
        if(admin==msg.sender) {
            allOrgs.push(Organisation(bankName, bankAddress, 0, 0, bankRegistrationNumber));
            isAddedToOrgListFlag = true;
            return isAddedToOrgListFlag;
        }
    
        return isAddedToOrgListFlag;
    }

    // Function is used to add the KYC request to the KYC_Request requests list.
    // Else assign IsAllowed to true. 
    // @param userName - customer name as string
    // @param dataHash - customer data as string
    // @return value “1” to determine the status of success, value “0” for the failure of the function.
    function addRequest(string memory userName, string memory dataHash) public payable returns(uint){
        //bool isAllowedValue;
        for(uint i = 0; i < allOrgs.length; ++ i) {
            if((allOrgs[i].ethAddress == msg.sender)) {
                // Check the rating of the bank
                    allRequests.push(KYC_Request(userName, msg.sender, dataHash,true));
                //return "1"-Success
                return 1;
            }
        }
        //return "0" - Failure of the function
        return 0;
    }
    
    // Function will add a customer to the customer list. 
    // If IsAllowed is false then don't process the request. 
    // @param userName - customer name as the string
    // @param dataHash - customer data as string
    // @return value “1” to determine the status of success
    // @return value “0” for the failure of the function.
    function addCustomer(string memory userName, string memory dataHash) public payable returns(uint) {
        //  throw error if username already in use
        for(uint i = 0;i < allCustomers.length; ++ i) {
            if(stringsEquals(allCustomers[i].uname, userName))
                // Failure of the function as user already exists
                return 0;
        }
        
        // If IsAllowed is false then dont process the request.
        for(uint i = 0; i < allRequests.length; ++i) {
            if(stringsEquals(allRequests[i].uname, userName) && allRequests[i].orgAddress == msg.sender && stringsEquals(allRequests[i].dataHash,dataHash)) {
                allCustomers.push(Customer(userName, dataHash, 0, 0, msg.sender, "0"));
                // set rating = 0, upvotes = 0, bank = current node, password = 0
                return 1;
            }
        }
        // If request doesnot exists in the KYC_Request list.
        return 0;
    }
    
    // Function will remove the request from the requests list.
    // @param userName - customer name as string
    // @param dataHash - customer data as string
    // @return value “1” to determine the status of success 
    //         value “0” for the failure of the function.
    function removeRequest(string memory userName, string memory dataHash) public payable returns(uint){
         for(uint i = 0; i < allRequests.length; ++ i) {
            if(stringsEquals(allRequests[i].uname, userName) && allRequests[i].orgAddress == msg.sender && stringsEquals(allRequests[i].dataHash,dataHash)) {
                //Remove the request from the requestlist and send status as "1"
                    for(uint j = i+1;j < allRequests.length; ++ j) {
                        allRequests[i-1] = allRequests[i];
                    }
                    allRequests.pop();
                    return 1;
            }
        }
        return 0;
    }


    // Function will remove the customer from the customer list.
    // @param userName - customerName
    // @return value “1” to determine the status of success
    //         value “0” for the failure of the function
    function removeCustomer(string memory userName) public payable returns(uint) {
        for(uint i = 0; i < allCustomers.length; ++ i) {
            if(stringsEquals(allCustomers[i].uname, userName)) {
                for(uint j = i+1;j < allCustomers.length; ++ j) {
                    allCustomers[i-1] = allCustomers[i];
                }
                allCustomers.pop();
                return 1;
            }
        }
        //  throw error if userName not found
        return 0;
    }
    
    // Function allows a bank to view details of a customer.
    // @param userName - customer name as string.
    // @param password - password for the user.
    // If the password is not set for the customer, then the incoming password string should be equal to "0".
    // @return dataHash - hash of the customer data in form of a string
    function viewCustomer(string memory userName,string memory password) public view returns(string memory) {
        for(uint i = 0; i < allCustomers.length; ++ i) {
            if(stringsEquals(allCustomers[i].uname, userName) && stringsEquals(allCustomers[i].password, password)) {
                return allCustomers[i].dataHash;
            }
        }
        return "Customer not found in the list!";
    }
    

 
    // Function allows a organization to cast an upvote for a customer. 
    // This vote from a organization means that it accepts the customer details as well acknowledge the KYC process done by some organization on the customer.
    // You also need to update the rating for a customer in this function.
    // The rating is calculated as the number of upvotes for the customer/total number of organization. 
    // If rating is more than 0.5, then you can add the customer to the final_customer list.
    // @param userName as customer name
    // @return “1” to determine the status of success
    //   value “0” for the failure of the function.
    function updateRatingCustomer(string memory userName) public payable returns(uint) {
        //Total number of banks
        uint totalNumberOfOrgs = allOrgs.length;
        for(uint i = 0; i < allCustomers.length; ++ i) {
            if(stringsEquals(allCustomers[i].uname, userName)) {
                    allCustomers[i].upvotes ++;
                    allCustomers[i].rating += (allCustomers[i].upvotes/totalNumberOfOrgs);
                    if(allCustomers[i].rating*10 >= 0.5*10){
                        allVerifiedCustomers.push(VerifiedCustomer(allCustomers[i].uname,allCustomers[i].dataHash,allCustomers[i].rating,allCustomers[i].upvotes,allCustomers[i].org,allCustomers[i].password));
                    }
                return 1;
            }
        }
        //  throw error if organization not found
        return 0;
    }
    
    // Function is used to fetch the details of FinalCustomer
    // @param userName - Customer name
    // @return address - bank address
    function showFinalCustomer() public view returns(string memory){
        string memory finalCustomerList;
        for(uint i = 0; i < allVerifiedCustomers.length; ++ i) {
                finalCustomerList = string(abi.encodePacked(allVerifiedCustomers[i].uname, " ", allVerifiedCustomers[i].rating, " ", allVerifiedCustomers[i].upvotes));
        }
        return finalCustomerList;
    }
    
    // Function is used to fetch customer rating from the smart contract.
    // @param userName as customer name
    // @returns rating as unsigned integer
    function getCustomerRating(string memory userName) public payable returns(uint) {
        for(uint i = 0; i < allCustomers.length; ++ i) {
            if(stringsEquals(allCustomers[i].uname, userName)) {
                return allCustomers[i].rating;
            }
        }
        return 0;
    }
    
    

    // Utility Function to check the equality of two string variables
    function stringsEquals(string storage _a, string memory _b) internal view returns (bool) {
        bytes storage a = bytes(_a);
        bytes memory b = bytes(_b); 
        if (a.length != b.length)
            return false;
        for (uint i = 0; i < a.length; i ++)
        {
            if (a[i] != b[i])
                return false;
        }
        return true;
    }
}