# BitchatNostr

Swift SPM package — BitChat-over-Nostr transport for iOS and macOS.

Implements NIP-17 gift-wrap private messages, async relay client (NIP-01),
geohash relay discovery, and helpers for embedding BitChat binary packets
inside Nostr events.

## Installation

```swift
// Package.swift
.package(url: "https://github.com/bitchat-sdk/BitchatNostr", from: "0.1.0")
```

## Usage

```swift
import BitchatNostr

// Embed a BitChat packet in a Nostr event
let b64 = NostrEmbeddedBitChat.encodePacket(wireBytes)

// Extract a BitChat packet from a received Nostr event
if let embedded = NostrEmbeddedBitChat.extractPacket(from: event) {
    let packet = BinaryProtocol.decode(embedded.packetData)
}

// Build a NIP-17 DM rumor
let rumor = NostrProtocol.buildDMRumor(
    content: b64,
    senderPubkey: myPubkey,
    recipientPubkey: theirPubkey
)
```

## Tor support

When the Tor/Arti package is present, `NostrRelayManager` and `GeoRelayDirectory`
route traffic through Tor automatically. Without Tor, they fall back to plain
`URLSession`/`URLSessionWebSocketTask`.

## License

Unlicense — public domain.
