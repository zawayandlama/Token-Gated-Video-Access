# 🎬 Token-Gated Video Access Smart Contract

![Stacks](https://img.shields.io/badge/Stacks-Blockchain-orange) ![Clarity](https://img.shields.io/badge/Language-Clarity-blue) ![License](https://img.shields.io/badge/License-MIT-green)

> **Empowering content creators with decentralized video monetization** 🚀

## 📋 Table of Contents
- [Overview](#-overview)
- [Features](#-features)
- [Getting Started](#-getting-started)
- [Usage](#-usage)
- [Contract Functions](#-contract-functions)
- [Pricing Models](#-pricing-models)
- [Development](#-development)
- [Testing](#-testing)
- [Contributing](#-contributing)

## 🎯 Overview

Token-Gated Video Access is a revolutionary smart contract that enables content creators to monetize their videos directly on the Stacks blockchain. Say goodbye to traditional platform dependencies and hello to true creator ownership! 💪

### 🌟 Why This Matters

- **🎨 Creator Empowerment**: Direct monetization without middlemen
- **🔐 True Ownership**: Transparent access rights on blockchain
- **💰 Flexible Pricing**: Multiple access tiers for different audiences
- **🌐 Censorship Resistant**: Decentralized storage integration ready
- **📊 Analytics**: Built-in view tracking and revenue monitoring

## ✨ Features

### 🎥 Video Management
- **Create Videos**: Upload with metadata, pricing, and season organization
- **Access Control**: Secure token-gated viewing system
- **Status Management**: Enable/disable videos instantly
- **Revenue Tracking**: Real-time earnings and view analytics

### 💳 Payment System
- **STX Payments**: Native Stacks token integration
- **Platform Fees**: Configurable fee structure (default 2.5%)
- **Instant Payouts**: Direct creator payments
- **Transparent Pricing**: All costs visible on-chain

### 🎟️ Access Tiers
1. **Single View** 🎬 - One-time access (24 hours)
2. **Season Pass** 📺 - Full season access (7 days)
3. **Lifetime Access** ♾️ - Permanent creator content access

## 🚀 Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- [Node.js](https://nodejs.org/) v16 or higher
- Stacks wallet (for testnet/mainnet deployment)

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd Token-Gated-Video-Access

# Install dependencies
npm install

# Run contract check
clarinet check
```

## 📖 Usage

### For Content Creators

#### 1. 📤 Create a Video
```clarity
(contract-call? .Token-Gated-Video-Access create-video 
  "My Amazing Video"              ;; title
  "Description of the content"    ;; description
  "QmHash123..."                  ;; IPFS hash
  u1000000                        ;; single view price (1 STX)
  u5000000                        ;; season price (5 STX)
  u20000000                       ;; lifetime price (20 STX)
  u1)                             ;; season ID
```

#### 2. 💰 Update Pricing
```clarity
(contract-call? .Token-Gated-Video-Access update-video-pricing 
  u1                 ;; video ID
  u2000000           ;; new single price (2 STX)
  u8000000           ;; new season price (8 STX)
  u30000000)         ;; new lifetime price (30 STX)
```

#### 3. 🔄 Toggle Video Status
```clarity
(contract-call? .Token-Gated-Video-Access toggle-video-status u1)
```

### For Viewers

#### 1. 🎬 Purchase Single Access
```clarity
(contract-call? .Token-Gated-Video-Access purchase-single-access u1)
```

#### 2. 📺 Purchase Season Access
```clarity
(contract-call? .Token-Gated-Video-Access purchase-season-access 
  'SP1234...creator-address 
  u1                        ;; season ID
  u5000000)                 ;; price in microSTX
```

#### 3. ♾️ Purchase Lifetime Access
```clarity
(contract-call? .Token-Gated-Video-Access purchase-lifetime-access 
  'SP1234...creator-address
  u20000000)                ;; price in microSTX
```

#### 4. 🔍 Check Access
```clarity
(contract-call? .Token-Gated-Video-Access has-access 
  'SP5678...your-address 
  u1)                      ;; video ID
```

## 🛠️ Contract Functions

### Public Functions

| Function | Description | Parameters |
|----------|-------------|------------|
| `create-video` | Create new video content | title, description, hash, prices, season-id |
| `purchase-single-access` | Buy single view access | video-id |
| `purchase-season-access` | Buy season pass | creator, season-id, price |
| `purchase-lifetime-access` | Buy lifetime access | creator, price |
| `toggle-video-status` | Enable/disable video | video-id |
| `update-video-pricing` | Update video prices | video-id, new-prices |
| `set-platform-fee` | Update platform fee (owner only) | fee-basis-points |

### Read-Only Functions

| Function | Description | Returns |
|----------|-------------|----------|
| `has-access` | Check user access to video | boolean |
| `get-video-details` | Get video information | video data |
| `get-user-access-info` | Get user access details | access data |
| `get-creator-earnings` | Get creator earnings | earnings data |
| `get-platform-fee` | Get current platform fee | fee percentage |
| `get-total-videos` | Get total video count | number |

## 💰 Pricing Models

### Access Duration
- **Single Access**: 1,440 blocks (~24 hours)
- **Season Access**: 10,080 blocks (~7 days)  
- **Lifetime Access**: Permanent

### Fee Structure
- **Platform Fee**: 2.5% (250 basis points) - configurable
- **Creator Revenue**: 97.5% of payment
- **No Hidden Fees**: All costs transparent

## 🔧 Development

### Project Structure
```
Token-Gated-Video-Access/
├── contracts/
│   └── Token-Gated-Video-Access.clar    # Main contract
├── tests/
│   └── Token-Gated-Video-Access.test.ts # Test suite
├── settings/
│   └── Devnet.toml                      # Network config
└── Clarinet.toml                        # Project config
```

### Contract Architecture
- **Data Maps**: Efficient storage for videos, access rights, earnings
- **Access Control**: Multi-tier permission system
- **Payment Processing**: Secure STX transfers with fee distribution
- **Time-based Access**: Block-height based expiration system

## 🧪 Testing

```bash
# Run all tests
npm test

# Run specific test
npm test -- --testNamePattern="create-video"

# Check contract syntax
clarinet check

# Run in console mode
clarinet console
```

### Test Coverage
- ✅ Video creation and management
- ✅ Access purchase flows
- ✅ Permission validation
- ✅ Payment processing
- ✅ Fee calculations
- ✅ Error handling

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines:

1. 🍴 Fork the repository
2. 🌿 Create a feature branch
3. ✅ Add tests for new features
4. 🚀 Submit a pull request

### Development Setup
```bash
# Install development dependencies
npm install

# Run linter
npm run lint

# Format code
npm run format
```

## 📜 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🔗 Links

- [Stacks Documentation](https://docs.stacks.co/)
- [Clarity Language Reference](https://docs.stacks.co/clarity/)
- [Clarinet Documentation](https://docs.hiro.so/clarinet/)

---

**Built with ❤️ for the decentralized creator economy** 🌟
