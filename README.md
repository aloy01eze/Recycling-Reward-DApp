# EcoChain - A Blockchain-Based Recycling Incentive DApp

EcoChain is a decentralized application (DApp) built on the Stacks blockchain using the Clarity smart contract language. It incentivizes recycling by rewarding users with tokens when they properly dispose of recyclable items within a defined geo-fence.

## Features

* Track Recycled Items: Users can submit details of recycled items including geolocation.
* Geo-Fencing: Ensures that recycling only counts when done in allowed areas.
* Earn Tokens: Verified recycling actions reward users with `eco-token` fungible tokens.
* Leaderboard: Tracks users by the number of items recycled.
* Token Redemption: Users can redeem earned tokens.
* Token Donations: Users can donate tokens to an NGO for community support.

## Constants

* `CONTRACT-OWNER`: The owner of the smart contract.
* `eco-token`: Fungible token rewarded for recycling.
* `eco-ngo`: Principal address of the beneficiary NGO.
* Error constants:

  * `ERR-NOT-AUTHORIZED (u100)`
  * `ERR-INVALID-ID (u101)`
  * `ERR-GEO-FENCE (u102)`
  * `ERR-ALREADY-VERIFIED (u103)`
  * `ERR-INSUFFICIENT-BALANCE (u104)`

## Data Structures

### `recycled-items`

Tracks each unique item recycled per user:

```clarity
{ item-id: string, user: principal } => { timestamp, latitude, longitude, verified }
```

### `user-balances`

User address mapped to their `eco-token` balance.

### `leaderboard`

Tracks the total number of items recycled by each user.

## Public Functions

### `recycle-item`

```clarity
(recycle-item (item-id string) (latitude int) (longitude int)) : (response bool uint)
```

Submits a recycled item and rewards the user.

### `redeem-tokens`

```clarity
(redeem-tokens (amount uint)) : (response bool uint)
```

Burns `eco-token` in exchange for off-chain rewards.

### `donate-tokens`

```clarity
(donate-tokens (amount uint)) : (response bool uint)
```

Transfers `eco-token` to the `eco-ngo`.

### `get-leaderboard`

```clarity
(get-leaderboard (user principal)) : { total-recycled: uint }
```

### `get-balance`

```clarity
(get-balance (user principal)) : uint
```

## Private Functions

### `is-valid-geo-fence`

Ensures submitted coordinates fall within a 0–1000 bounded box.

### `update-leaderboard`

Updates user's total recycled item count.

## Requirements

* Stacks Blockchain
* Clarity Language Support (via Clarinet or Hiro Platform)

## Testing

Use [Clarinet](https://docs.stacks.co/docs/clarity/clarinet/overview/) to test the contract:

```bash
clarinet test
```

## Future Improvements

* Expand geo-fence to include real-world coordinates
* Add NFT support for unique recycling badges
* Implement governance to allow eco-ngo changes

