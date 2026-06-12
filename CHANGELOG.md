# Changelog — BitchatNostr (Swift)

All notable changes follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Changed
- `NostrRelayManager` now deduplicates inbound events per subscription: when multiple relays serve the same subscription, only the first copy of an event reaches the handler. Duplicate drops are counted and surfaced via `debugDuplicateInboundEventDropCount` (upstream iOS PR #1331).
- Signature verification moved from the inbound parser to the delivery path, so invalid events are logged (and counted in relay stats) instead of silently discarded, and cannot poison the dedup cache (upstream iOS PR #1331).
- The pending-send queue is now capped at `TransportConfig.nostrPendingSendQueueCap` (200); the oldest queued sends are dropped on overflow (upstream iOS PR #1331).
- Per-event inbound debug logging is now sampled (every 100th event) instead of logged per event (upstream iOS PR #1332).
- `GeoRelayDirectory.closestRelays` now breaks distance ties by host, so every device with the same directory picks the same relay set — publishers and subscribers must agree on relays (upstream iOS PR #1333).

### Notes
- Requires BitchatProtocol > 0.1.1 (new `TransportConfig` constants). Release BitchatProtocol first, per the usual protocol-core → nostr order.

## [0.1.1] — 2026-05-05

### Changed
- Internal: centralize string trimming via `StringProtocol.trimmed` / `trimmedOrNilIfEmpty` helpers (upstream iOS PR #1079). Refactor only — no public API or wire-format change.

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

[0.1.1]: https://github.com/bitchat-sdk/BitchatNostr/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/bitchat-sdk/BitchatNostr/releases/tag/0.1.0

[Unreleased]: https://github.com/bitchat-sdk/BitchatNostr/compare/0.1.1...HEAD