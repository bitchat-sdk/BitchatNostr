# Changelog — BitchatNostr (Swift)

All notable changes follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.1.0] — 2026-03-22

Initial GA release.

### Added
- `NostrRelayManager` — `ObservableObject` managing multiple relay connections with reconnect logic
  - `connect()` / `disconnect()` / `ensureConnections(to:)`
  - `subscribe(filter:id:relayUrls:handler:onEOSE:)` / `unsubscribe(id:)`
  - `sendEvent(_:to:)` — publish to specific relays
  - `publicGeohashRelayURLs(for:count:)` — geo-nearest relay selection
  - `shared` singleton
- `GeoRelayDirectory` — geographic relay lookup by geohash or lat/lon
  - `Entry` with `host`, `lat`, `lon` fields
  - `closestRelays(toGeohash:count:)` / `closestRelays(toLat:lon:count:)`
  - `shared` singleton
- `NostrProtocol` — event construction and decryption helpers
  - `createPrivateMessage(...)` / `decryptPrivateMessage(...)`
  - `createEphemeralGeohashEvent(...)` / `createGeohashPresenceEvent(...)` / `createGeohashTextNote(...)`
  - `EventKind` enum: `.privateMessage`, `.geohashPresence`, etc.
  - `NostrEvent` Codable struct with `id`, `pubkey`, `kind`, `tags`, `content`, `sig`
  - `NostrError` error enum
- `NostrIdentity` — Codable value type for Nostr key pairs
  - `generate()` — generate a new random identity
  - `publicKeyHex` — hex-encoded public key
  - `schnorrSigningKey()` — extract P256 signing key
- `NostrIdentityBridge` — bridge between app keychain and `NostrIdentity`
  - `getCurrentNostrIdentity()` / `deriveIdentity(forGeohash:)`
- `NostrEmbeddedBitChat` — static helpers for embedding BitChat packets in Nostr events
  - `encodePMForNostr(...)`, `encodeAckForNostr(...)`, `encodeFileTransferForNostr(...)`
- `Bech32` — encode/decode with `Bech32Error`
- `XChaCha20Poly1305Compat` — compatibility wrapper for XChaCha20-Poly1305 encryption

### Protocol Compatibility
Compatible with NIP-01, NIP-17, and BitChat geohash presence protocol.

[0.1.0]: https://github.com/bitchat-sdk/BitchatNostr/releases/tag/0.1.0

[Unreleased]: https://github.com/bitchat-sdk/BitchatNostr/compare/0.1.0...HEAD