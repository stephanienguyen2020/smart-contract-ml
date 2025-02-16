# What is a fungible token?

Fungible tokens are digital assets that are interchangeable on a one-to-one basis, representing a uniform unit of value.

# Contract Details

This contract implements a basic fungible token with the following features:

## Storage

- `balances`: A mapping that tracks token balances for each address
- `totalSupply`: The total amount of tokens in circulation
- `owner`: The address of the token contract owner who has special minting privileges

## Core Functions

### Constructor

- Initializes the token contract with an initial supply
- Sets the contract deployer as the owner
- Mints the initial supply to the owner's address

### Mint

- Allows the owner to create new tokens
- Only the contract owner can mint tokens
- Increases both the recipient's balance and total supply

### BalanceOf

- Public view function to check the token balance of any address
- Returns the amount of tokens held by the specified account

### Transfer

- Allows users to transfer tokens to other addresses
- Checks if the sender has sufficient balance
- Updates both sender and recipient balances accordingly

## Security Features

- Owner-only minting restriction
- Balance checks before transfers
- Safe arithmetic operations using Solidity 0.8.17's built-in overflow protection
