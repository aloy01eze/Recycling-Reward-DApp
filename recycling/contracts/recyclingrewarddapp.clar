;; EcoChain - Blockchain-Based Recycling Incentive DApp
;; A smart contract that incentivizes recycling by rewarding users with tokens

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-ID (err u101))
(define-constant ERR-GEO-FENCE (err u102))
(define-constant ERR-ALREADY-VERIFIED (err u103))
(define-constant ERR-INSUFFICIENT-BALANCE (err u104))

;; NGO principal address (can be updated by contract owner)
(define-data-var eco-ngo principal tx-sender)

;; Define fungible token
(define-fungible-token eco-token)

;; Data structures
;; Map to track recycled items per user
(define-map recycled-items 
  { item-id: (string-ascii 50), user: principal }
  { 
    timestamp: uint,
    latitude: int,
    longitude: int,
    verified: bool
  }
)

;; Map to track user token balances
(define-map user-balances principal uint)

;; Map to track leaderboard (total items recycled per user)
(define-map leaderboard principal uint)

;; Private function to validate geo-fence
(define-private (is-valid-geo-fence (latitude int) (longitude int))
  (and 
    (>= latitude 0)
    (<= latitude 1000)
    (>= longitude 0)
    (<= longitude 1000)
  )
)

;; Private function to update leaderboard
(define-private (update-leaderboard (user principal))
  (let ((current-count (default-to u0 (map-get? leaderboard user))))
    (map-set leaderboard user (+ current-count u1))
  )
)

;; Public function to recycle an item
(define-public (recycle-item (item-id (string-ascii 50)) (latitude int) (longitude int))
  (let (
    (item-key { item-id: item-id, user: tx-sender })
    (existing-item (map-get? recycled-items item-key))
  )
    ;; Check if item already exists
    (asserts! (is-none existing-item) ERR-ALREADY-VERIFIED)
    
    ;; Validate geo-fence
    (asserts! (is-valid-geo-fence latitude longitude) ERR-GEO-FENCE)
    
    ;; Record the recycled item
    (map-set recycled-items item-key {
      timestamp: stacks-block-height,
      latitude: latitude,
      longitude: longitude,
      verified: true
    })
    
    ;; Update leaderboard
    (update-leaderboard tx-sender)
    
    ;; Mint and transfer eco-tokens to user (10 tokens per item)
    (try! (ft-mint? eco-token u10 tx-sender))
    
    ;; Update user balance tracking
    (let ((current-balance (default-to u0 (map-get? user-balances tx-sender))))
      (map-set user-balances tx-sender (+ current-balance u10))
    )
    
    (ok true)
  )
)

;; Public function to redeem tokens
(define-public (redeem-tokens (amount uint))
  (let ((user-balance (ft-get-balance eco-token tx-sender)))
    ;; Check if user has sufficient balance
    (asserts! (>= user-balance amount) ERR-INSUFFICIENT-BALANCE)
    
    ;; Burn the tokens
    (try! (ft-burn? eco-token amount tx-sender))
    
    ;; Update user balance tracking
    (let ((current-balance (default-to u0 (map-get? user-balances tx-sender))))
      (map-set user-balances tx-sender (- current-balance amount))
    )
    
    (ok true)
  )
)

;; Public function to donate tokens to NGO
(define-public (donate-tokens (amount uint))
  (let ((user-balance (ft-get-balance eco-token tx-sender)))
    ;; Check if user has sufficient balance
    (asserts! (>= user-balance amount) ERR-INSUFFICIENT-BALANCE)
    
    ;; Transfer tokens to NGO
    (try! (ft-transfer? eco-token amount tx-sender (var-get eco-ngo)))
    
    ;; Update user balance tracking
    (let ((current-balance (default-to u0 (map-get? user-balances tx-sender))))
      (map-set user-balances tx-sender (- current-balance amount))
    )
    
    (ok true)
  )
)

;; Read-only function to get user's leaderboard position
(define-read-only (get-leaderboard (user principal))
  (let ((total-recycled (default-to u0 (map-get? leaderboard user))))
    { total-recycled: total-recycled }
  )
)

;; Read-only function to get user's token balance
(define-read-only (get-balance (user principal))
  (ft-get-balance eco-token user)
)

;; Read-only function to get recycled item details
(define-read-only (get-recycled-item (item-id (string-ascii 50)) (user principal))
  (map-get? recycled-items { item-id: item-id, user: user })
)

;; Read-only function to get NGO address
(define-read-only (get-ngo-address)
  (var-get eco-ngo)
)

;; Admin function to update NGO address (only contract owner)
(define-public (update-ngo-address (new-ngo principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set eco-ngo new-ngo)
    (ok true)
  )
)

;; Read-only function to get token info
(define-read-only (get-token-info)
  {
    name: "EcoToken",
    symbol: "ECO",
    decimals: u0,
    total-supply: (ft-get-supply eco-token)
  }
)
