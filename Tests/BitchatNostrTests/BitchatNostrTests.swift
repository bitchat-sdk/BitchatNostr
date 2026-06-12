import XCTest
@testable import BitchatNostr
import BitchatProtocol

final class BitchatNostrTests: XCTestCase {

    func testEncodePMForNostr() throws {
        let sender = PeerID(publicKey: Data(repeating: 0xAA, count: 32))
        let recipient = PeerID(publicKey: Data(repeating: 0xBB, count: 32))
        let result = NostrEmbeddedBitChat.encodePMForNostr(
            content: "Hello, BitChat!",
            messageID: "test-msg-001",
            recipientPeerID: recipient,
            senderPeerID: sender
        )
        XCTAssertNotNil(result, "encodePMForNostr should return a non-nil string")
        XCTAssertFalse(result!.isEmpty, "encoded string should not be empty")
    }

    func testBech32RoundTrip() throws {
        let testData = Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05])
        let encoded = try Bech32.encode(hrp: "npub", data: testData)
        XCTAssertFalse(encoded.isEmpty, "Bech32 encode should produce output")
        let decoded = try Bech32.decode(encoded)
        XCTAssertEqual(decoded.hrp, "npub")
        XCTAssertEqual(decoded.data, testData)
    }

    @MainActor
    func testGeoRelayDirectoryExists() {
        let directory = GeoRelayDirectory.shared
        XCTAssertNotNil(directory)
    }

    @MainActor
    func testClosestRelaysBreaksDistanceTiesByHost() {
        // Four hosts at identical coordinates: order must be deterministic by host.
        let directory = GeoRelayDirectory(entries: [
            .init(host: "delta.example", lat: 10, lon: 10),
            .init(host: "bravo.example", lat: 10, lon: 10),
            .init(host: "charlie.example", lat: 10, lon: 10),
            .init(host: "alpha.example", lat: 10, lon: 10),
        ])
        let relays = directory.closestRelays(toLat: 10, lon: 10, count: 3)
        XCTAssertEqual(relays, ["wss://alpha.example", "wss://bravo.example", "wss://charlie.example"])
    }

    @MainActor
    func testClosestRelaysOrdersByDistanceFirst() {
        let directory = GeoRelayDirectory(entries: [
            .init(host: "far.example", lat: 50, lon: 50),
            .init(host: "near.example", lat: 10.1, lon: 10.1),
            .init(host: "mid.example", lat: 20, lon: 20),
        ])
        let relays = directory.closestRelays(toLat: 10, lon: 10, count: 2)
        XCTAssertEqual(relays, ["wss://near.example", "wss://mid.example"])
    }

    @MainActor
    func testInboundEventDedupDeliversFirstCopyOnly() {
        let manager = NostrRelayManager()
        XCTAssertTrue(manager.shouldDeliverInboundEvent(subscriptionID: "sub-a", eventID: "event-1"))
        XCTAssertFalse(manager.shouldDeliverInboundEvent(subscriptionID: "sub-a", eventID: "event-1"))
        XCTAssertEqual(manager.debugDuplicateInboundEventDropCount, 1)
        XCTAssertEqual(manager.debugDuplicateInboundEventDropCount(forSubscriptionID: "sub-a"), 1)

        // Same event on a different subscription is independent.
        XCTAssertTrue(manager.shouldDeliverInboundEvent(subscriptionID: "sub-b", eventID: "event-1"))
    }

    @MainActor
    func testUnsubscribeClearsDedupStateForSubscription() {
        let manager = NostrRelayManager()
        XCTAssertTrue(manager.shouldDeliverInboundEvent(subscriptionID: "sub-a", eventID: "event-1"))
        XCTAssertTrue(manager.shouldDeliverInboundEvent(subscriptionID: "sub-b", eventID: "event-2"))

        manager.unsubscribe(id: "sub-a")

        // sub-a's history is gone; sub-b's is intact.
        XCTAssertTrue(manager.shouldDeliverInboundEvent(subscriptionID: "sub-a", eventID: "event-1"))
        XCTAssertFalse(manager.shouldDeliverInboundEvent(subscriptionID: "sub-b", eventID: "event-2"))
    }

    @MainActor
    func testInboundEventDedupCacheTrimsBeyondCap() {
        let manager = NostrRelayManager()
        for i in 0...(TransportConfig.nostrInboundEventDedupCap) {
            XCTAssertTrue(manager.shouldDeliverInboundEvent(subscriptionID: "sub", eventID: "event-\(i)"))
        }
        // The oldest keys were trimmed, so the very first event is deliverable again.
        XCTAssertTrue(manager.shouldDeliverInboundEvent(subscriptionID: "sub", eventID: "event-0"))
    }
}
