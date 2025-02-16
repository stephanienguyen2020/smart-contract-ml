// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import Pyth Network interfaces for price feed functionality
import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";

/// @title Market Assistant
/// @notice A smart contract that tracks crypto prices and provides market movement alerts
contract MarketAssistant {
    // Interface to interact with Pyth Network oracle
    IPyth pyth;
    
    /// @notice Structure to store price data for a crypto asset
    /// @param priceFeedId Unique identifier for the crypto asset in Pyth Network
    /// @param price Current price in USDT
    /// @param timestamp Time when the price was last updated
    struct PriceData {
        bytes32 priceFeedId;
        int price;
        uint timestamp;                  
    }    
    
    /// @notice Initialize the contract with Pyth Network oracle address
    /// @param pythContract Address of the Pyth Network contract on the current chain
    constructor(address pythContract) {
        pyth = IPyth(pythContract);
    } 
    
    // Maps asset IDs to their price thresholds set by users
    mapping(bytes32 => int) public priceThresholds;
    // Maps asset IDs to their latest price data
    mapping(bytes32 => PriceData) public lastPrices;  
    
    /// @notice Emitted when price reaches or exceeds the set threshold
    event ThresholdExceeded(bytes32 indexed priceFeedId, int price);
    /// @notice Emitted when price increases from the last update
    event PriceIncrease(bytes32 indexed priceFeedId, int previousPrice, int currentPrice, int changePercentage);
    /// @notice Emitted when price decreases from the last update
    event PriceDecrease(bytes32 indexed priceFeedId, int previousPrice, int currentPrice, int changePercentage);
    
    /// @notice Updates the price for a given crypto asset
    /// @param priceUpdate Byte array containing latest price information from Pyth
    /// @param priceFeedId Unique identifier for the crypto asset
    /// @return Current price of the asset
    function updatePrice(bytes[] calldata priceUpdate, bytes32 priceFeedId) public payable returns(int) {
        // Calculate and pay the required fee for updating price feed
        uint fee = pyth.getUpdateFee(priceUpdate);     
        pyth.updatePriceFeeds{ value: fee }(priceUpdate);  
        
        // Get latest price data, ensuring it's not older than 60 seconds
        PythStructs.Price memory currentPrice = pyth.getPriceNoOlderThan(priceFeedId, 60);        
        
        // If we have historical price data, check for price changes
        if (lastPrices[priceFeedId].price != 0) {
            int priceChange = calculatePriceChange(lastPrices[priceFeedId].price, currentPrice.price);
            if (priceChange > 0) {
                emit PriceIncrease(priceFeedId, lastPrices[priceFeedId].price, currentPrice.price, priceChange);
            } else if (priceChange < 0) {
                emit PriceDecrease(priceFeedId, lastPrices[priceFeedId].price, currentPrice.price, priceChange); 
            }                 
        }
        
        // Check if price has reached or exceeded threshold
        if (priceThresholds[priceFeedId] != 0 && currentPrice.price >= priceThresholds[priceFeedId]) {
            emit ThresholdExceeded(priceFeedId, currentPrice.price);    
        }        
        
        // Update stored price data
        lastPrices[priceFeedId] = PriceData(priceFeedId, currentPrice.price, block.timestamp);        
        return currentPrice.price;     
    }  

    /// @notice Calculates percentage change between two prices
    /// @param previousPrice The last recorded price
    /// @param currentPrice The new price
    /// @return Percentage change in price (positive for increase, negative for decrease)
    function calculatePriceChange(int previousPrice, int currentPrice) internal pure returns (int) {
        if (previousPrice == 0) return 0;
        return ((currentPrice - previousPrice) * 100) / previousPrice;  
    }   
    
    /// @notice Sets a price threshold for a given crypto asset
    /// @param priceFeedId Unique identifier for the crypto asset
    /// @param threshold Price level at which to trigger an alert
    function setPriceThreshold(bytes32 priceFeedId, int threshold) public {
        priceThresholds[priceFeedId] = threshold;
    }    
      
}
