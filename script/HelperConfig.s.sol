//SPDX-License-Identifier: MIT

//1. Deploy mocks when we are on a local Anvil chain
//2. keep track of contract address across different chains
// Sepolia ETH/USD
// Mainnet ETH/USD
// they both have diferent addresses

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
    //if we are on a local Anvil chain, deploy mocks
    //otherwise, grab the existing address from the live network
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8; //2000.00000000
    // 2000.00000000 * 10**8 = 2000000000000000000000

    struct NetworkConfig {
        address priceFeed; //ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaETHConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetETHConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilETHConfig();
        }
    }    

    function getSepoliaETHConfig() public pure returns (NetworkConfig memory) {
        //price feed Address
        NetworkConfig memory sepoliaConfig = NetworkConfig ({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getMainnetETHConfig() public pure returns (NetworkConfig memory) {
        //price feed Address
        NetworkConfig memory ethConfig = NetworkConfig ({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return ethConfig;
    }

    function getOrCreateAnvilETHConfig() public returns (NetworkConfig memory) {
        if (
            activeNetworkConfig.priceFeed != address(0)
        ) {
            return activeNetworkConfig;
        }
        
        //price feed Address

        // 1. Deploy mocks when we are on a local Anvil chain
        // 2. Return the mock address

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast(); 

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
    }
}