
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-insufficient-payment (err u103))
(define-constant err-access-denied (err u104))
(define-constant err-invalid-pricing (err u105))
(define-constant err-video-not-active (err u106))
(define-constant err-invalid-duration (err u107))
(define-constant err-unauthorized (err u108))

(define-constant access-type-single u1)
(define-constant access-type-season u2)
(define-constant access-type-lifetime u3)

(define-data-var video-counter uint u0)
(define-data-var platform-fee-basis-points uint u250)

(define-map videos
  { video-id: uint }
  {
    creator: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    content-hash: (string-ascii 64),
    price-single: uint,
    price-season: uint,
    price-lifetime: uint,
    season-id: uint,
    created-at: uint,
    is-active: bool,
    total-views: uint,
    total-revenue: uint
  }
)

(define-map video-access
  { user: principal, video-id: uint }
  {
    access-type: uint,
    granted-at: uint,
    expires-at: (optional uint),
    season-id: uint
  }
)

(define-map season-access
  { user: principal, creator: principal, season-id: uint }
  {
    granted-at: uint,
    expires-at: (optional uint)
  }
)

(define-map lifetime-access
  { user: principal, creator: principal }
  {
    granted-at: uint
  }
)

(define-map user-balances
  { user: principal }
  { balance: uint }
)

(define-map creator-earnings
  { creator: principal }
  { total-earned: uint, withdrawable: uint }
)

(define-public (create-video 
    (title (string-ascii 100))
    (description (string-ascii 500))
    (content-hash (string-ascii 64))
    (price-single uint)
    (price-season uint)
    (price-lifetime uint)
    (season-id uint))
  (let
    (
      (video-id (+ (var-get video-counter) u1))
      (current-height (default-to u0 (get-stacks-block-info? time u0)))
    )
    (asserts! (> price-single u0) err-invalid-pricing)
    (asserts! (> price-season u0) err-invalid-pricing)
    (asserts! (> price-lifetime u0) err-invalid-pricing)
    (asserts! (>= price-lifetime price-season) err-invalid-pricing)
    (asserts! (>= price-season price-single) err-invalid-pricing)
    
    (map-set videos
      { video-id: video-id }
      {
        creator: tx-sender,
        title: title,
        description: description,
        content-hash: content-hash,
        price-single: price-single,
        price-season: price-season,
        price-lifetime: price-lifetime,
        season-id: season-id,
        created-at: current-height,
        is-active: true,
        total-views: u0,
        total-revenue: u0
      }
    )
    
    (var-set video-counter video-id)
    (ok video-id)
  )
)

(define-public (purchase-single-access (video-id uint))
  (let
    (
      (video-data (unwrap! (map-get? videos { video-id: video-id }) err-not-found))
      (price (get price-single video-data))
      (creator (get creator video-data))
      (platform-fee (/ (* price (var-get platform-fee-basis-points)) u10000))
      (creator-amount (- price platform-fee))
      (current-height (default-to u0 (get-stacks-block-info? time u0)))
    )
    (asserts! (get is-active video-data) err-video-not-active)
    (asserts! (>= (stx-get-balance tx-sender) price) err-insufficient-payment)
    
    (try! (stx-transfer? platform-fee tx-sender contract-owner))
    (try! (stx-transfer? creator-amount tx-sender creator))
    
    (map-set video-access
      { user: tx-sender, video-id: video-id }
      {
        access-type: access-type-single,
        granted-at: current-height,
        expires-at: (some (+ current-height u1440)),
        season-id: (get season-id video-data)
      }
    )
    
    (map-set videos
      { video-id: video-id }
      (merge video-data {
        total-views: (+ (get total-views video-data) u1),
        total-revenue: (+ (get total-revenue video-data) price)
      })
    )
    
    (update-creator-earnings creator creator-amount)
    (ok true)
  )
)

(define-public (purchase-season-access (creator principal) (season-id uint) (price uint))
  (let
    (
      (platform-fee (/ (* price (var-get platform-fee-basis-points)) u10000))
      (creator-amount (- price platform-fee))
      (current-height (default-to u0 (get-stacks-block-info? time u0)))
    )
    (asserts! (> price u0) err-invalid-pricing)
    (asserts! (>= (stx-get-balance tx-sender) price) err-insufficient-payment)
    
    (try! (stx-transfer? platform-fee tx-sender contract-owner))
    (try! (stx-transfer? creator-amount tx-sender creator))
    
    (map-set season-access
      { user: tx-sender, creator: creator, season-id: season-id }
      {
        granted-at: current-height,
        expires-at: (some (+ current-height u10080))
      }
    )
    
    (update-creator-earnings creator creator-amount)
    (ok true)
  )
)

(define-public (purchase-lifetime-access (creator principal) (price uint))
  (let
    (
      (platform-fee (/ (* price (var-get platform-fee-basis-points)) u10000))
      (creator-amount (- price platform-fee))
      (current-height (default-to u0 (get-stacks-block-info? time u0)))
    )
    (asserts! (> price u0) err-invalid-pricing)
    (asserts! (>= (stx-get-balance tx-sender) price) err-insufficient-payment)
    
    (try! (stx-transfer? platform-fee tx-sender contract-owner))
    (try! (stx-transfer? creator-amount tx-sender creator))
    
    (map-set lifetime-access
      { user: tx-sender, creator: creator }
      { granted-at: current-height }
    )
    
    (update-creator-earnings creator creator-amount)
    (ok true)
  )
)

(define-public (toggle-video-status (video-id uint))
  (let
    (
      (video-data (unwrap! (map-get? videos { video-id: video-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender (get creator video-data)) err-unauthorized)
    
    (map-set videos
      { video-id: video-id }
      (merge video-data { is-active: (not (get is-active video-data)) })
    )
    (ok true)
  )
)

(define-public (update-video-pricing 
    (video-id uint)
    (new-price-single uint)
    (new-price-season uint)
    (new-price-lifetime uint))
  (let
    (
      (video-data (unwrap! (map-get? videos { video-id: video-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender (get creator video-data)) err-unauthorized)
    (asserts! (> new-price-single u0) err-invalid-pricing)
    (asserts! (> new-price-season u0) err-invalid-pricing)
    (asserts! (> new-price-lifetime u0) err-invalid-pricing)
    (asserts! (>= new-price-lifetime new-price-season) err-invalid-pricing)
    (asserts! (>= new-price-season new-price-single) err-invalid-pricing)
    
    (map-set videos
      { video-id: video-id }
      (merge video-data {
        price-single: new-price-single,
        price-season: new-price-season,
        price-lifetime: new-price-lifetime
      })
    )
    (ok true)
  )
)

(define-public (set-platform-fee (new-fee-basis-points uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-fee-basis-points u1000) err-invalid-pricing)
    (var-set platform-fee-basis-points new-fee-basis-points)
    (ok true)
  )
)

(define-read-only (has-access (user principal) (video-id uint))
  (let
    (
      (video-data (unwrap! (map-get? videos { video-id: video-id }) (ok false)))
      (creator (get creator video-data))
      (season-id (get season-id video-data))
      (current-height (default-to u0 (get-stacks-block-info? time u0)))
      (single-access (map-get? video-access { user: user, video-id: video-id }))
      (season-acc (map-get? season-access { user: user, creator: creator, season-id: season-id }))
      (lifetime-acc (map-get? lifetime-access { user: user, creator: creator }))
    )
    (ok
      (or
        (match single-access
          access-data (match (get expires-at access-data)
            expires (< current-height expires)
            true
          )
          false
        )
        (match season-acc
          access-data (match (get expires-at access-data)
            expires (< current-height expires)
            true
          )
          false
        )
        (is-some lifetime-acc)
      )
    )
  )
)

(define-read-only (get-video-details (video-id uint))
  (ok (map-get? videos { video-id: video-id }))
)

(define-read-only (get-user-access-info (user principal) (video-id uint))
  (ok (map-get? video-access { user: user, video-id: video-id }))
)

(define-read-only (get-creator-earnings (creator principal))
  (default-to { total-earned: u0, withdrawable: u0 }
    (map-get? creator-earnings { creator: creator })
  )
)

(define-read-only (get-platform-fee)
  (ok (var-get platform-fee-basis-points))
)

(define-read-only (get-total-videos)
  (ok (var-get video-counter))
)

(define-private (update-creator-earnings (creator principal) (amount uint))
  (let
    (
      (current-earnings (default-to { total-earned: u0, withdrawable: u0 }
        (map-get? creator-earnings { creator: creator })
      ))
    )
    (map-set creator-earnings
      { creator: creator }
      {
        total-earned: (+ (get total-earned current-earnings) amount),
        withdrawable: (+ (get withdrawable current-earnings) amount)
      }
    )
    true
  )
)

(define-read-only (get-videos-by-creator (creator principal))
  (ok {
    creator: creator,
    total-videos: (var-get video-counter)
  })
)
