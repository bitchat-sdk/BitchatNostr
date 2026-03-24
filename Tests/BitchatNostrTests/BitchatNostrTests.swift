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
}
