// SPDX-License-Identifier:Unlicensed

pragma solidity ^0.8.27;

import {Script} from "forge-std/Script.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol"; //before this the header for import was at script so to come back to main directory we use ..

contract DeploySimpleStorage is Script {
    function run() external returns (SimpleStorage) {
        vm.startBroadcast(); // everything after this line is sent to vmc
        SimpleStorage simpleStorage = new SimpleStorage();
        vm.stopBroadcast(); // everything before this line is sent to vmc
        return simpleStorage;
    }
}
