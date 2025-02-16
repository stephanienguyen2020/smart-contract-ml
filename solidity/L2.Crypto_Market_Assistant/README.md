# Crypto Market Assistant

A smart contract that helps users track cryptocurrency prices and market movements on-chain using the Pyth Network oracle. This assistant provides real-time price tracking, price change notifications, and customizable price threshold alerts.

## Overview

The Crypto Market Assistant leverages Pyth Network's decentralized oracle to:

- Track real-time cryptocurrency prices
- Monitor price movements and emit events for price increases/decreases
- Alert users when prices reach specified thresholds

## Key Components

### Pyth Network Integration

The contract uses Pyth Network for reliable price data:

- Pyth contract address on Sonic: `0x96124d1F6E44FfDf1fb5D6d74BB2DE1B7Fbe7376`
- Supports multiple blockchains and asset types
- Provides high-frequency price updates from 95+ data providers

### Data Structures

```
struct PriceData {
    bytes32 priceFeedId; // Unique identifier for the crypto asset
    int price; // Current price in USDT
    uint timestamp; // Time of last update
}
```

### State Variables

- `mapping(bytes32 => int) priceThresholds`: Stores user-defined price alerts
- `mapping(bytes32 => PriceData) lastPrices`: Tracks latest price data for each asset

### Events

- `ThresholdExceeded`: Triggered when price reaches user-defined threshold
- `PriceIncrease`: Emitted when price rises from previous update
- `PriceDecrease`: Emitted when price falls from previous update

## Core Functions

### Price Updates

```
function updatePrice(bytes[] calldata priceUpdate, bytes32 priceFeedId) public payable returns(int)
```

1. Calculates and pays required update fee
2. Updates price feed data on-chain
3. Checks for price changes and threshold crossings
4. Emits relevant events
5. Updates stored price data

### Price Threshold Management

```
function setPriceThreshold(bytes32 priceFeedId, int threshold) public
```

1. Allows users to set custom price thresholds for each asset
2. Emits `ThresholdSet` event when threshold is updated

### Price Change Calculation

```
function calculatePriceChange(int previousPrice, int currentPrice) internal pure returns (int)
```

1. Calculates percentage change between previous and current prices
2. Returns absolute percentage change

## Use Cases

1. **Market Monitoring**

   - Track real-time price movements
   - Receive notifications for significant price changes

2. **Price Alerts**

   - Set custom price thresholds
   - Get notified when prices reach target levels

3. **Trading Strategy Support**
   - Use price data for on-chain trading decisions
   - Integrate with automated trading systems

## Technical Notes

- Uses Pyth's `getPriceNoOlderThan` to ensure fresh price data (60-second maximum age)
- Requires payment of update fees in native tokens
- Price changes calculated as percentage movements
- All price data includes timestamp for freshness verification

For more information about Pyth Network price feeds and contract addresses, visit: https://docs.pyth.network/price-feeds/contract-addresses
