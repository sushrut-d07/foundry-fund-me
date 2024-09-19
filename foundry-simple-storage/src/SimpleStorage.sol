// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26; // stating our version

contract SimpleStorage {
    // contract is like class in java
    // Basic types : boolean, uint, int , address, bytes
    uint256 public myFavoriteNumber; //its visibility is internal if undefined
    // uint256[] listOfFavoriteNumbers;

    struct Person {
        // create your own type using struct
        uint256 favoriteNumber;
        string name;
    }

    mapping(string => uint256) public nameeToFavoriteNumber;

    //    Person public myfriend = Person({favoriteNumber: 9,name : "Medha"}); // to initialise a struct type we need to specify types on both sides
    // Person[] public listOfPeople; //dynamic array since number of members of the list not defined
    function store(uint256 _favoriteNumber) public virtual {
        //initialising a function //virtual keyword used to make override possible
        myFavoriteNumber = _favoriteNumber;
    }

    function retrieve() public view returns (uint256) {
        return myFavoriteNumber;
    }

    function addPerson(string memory _name, uint256 _favoriteNumber) public {
        //        Person memory newPerson = Person(_favoriteNumber,_name);
        //        listOfPeople.push(newPerson);
        nameeToFavoriteNumber[_name] = _favoriteNumber; //in mapping default type is 0, i.e if we dont have a key value pair initialised and we try to call it we get 0 as a response
    }
}
