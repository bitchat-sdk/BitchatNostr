import XCTest
@testable import BitchatNostr

final class BitchatNostrTests: XCTestCase {

    func testEncodeDecodeBase64() throws {
        let payload = Data("Hello, BitChat!".utf8)
        let encoded = NostrEmbeddedBitChat.encodePacket(payload)
        XCTAssertFalse(encoded.isEmpty)
        let decoded = NostrEmbeddedBitChat.decodePacket(encoded)
        XCTAssertEqual(decoded, payload)
    }

    func testExtractPacketFromEvent() throws {
        let payload = Data("test payload".utf8)
        let b64 = NostrEmbeddedBitChat.encodePacket(payload)
        let event = NostrEvent(
            id: "abc123",
            pubkey: "deadbeef",
            created_at: 0,
            kind: 1059,
            tags: [],
            content: b64,
            sig: ""
        )
        let extracted = NostrEmbeddedBitChat.extractPacket(from: event)
        XCTAssertNotNil(extracted)
        XCTAssertEqual(extracted?.packetData, payload)
    }
}
