// _EcosystemStubs.swift
// BitchatNostr
//
// Provides stubs for app-level services and the Tor package so BitchatNostr
// compiles as a standalone ecosystem package. Never used by the full app.
//
// TransportConfig is provided by BitchatProtocol (an explicit dependency).
//
// This is free and unencumbered software released into the public domain.

import Foundation
import Combine
import BitchatProtocol

// MARK: - NetworkActivationService stub
// In standalone mode, relay connections are always allowed and Tor is off.

@MainActor
final class NetworkActivationService: ObservableObject {
    static let shared = NetworkActivationService()
    @Published private(set) var activationAllowed: Bool = true
    @Published private(set) var userTorEnabled: Bool = false
    private init() {}
}

// MARK: - Tor stubs
// Only compiled when the Tor/Arti package is NOT available.

// MARK: - KeychainManager stub
// Provides a minimal keychain abstraction for standalone SDK use.

public protocol KeychainManagerProtocol {
    func saveIdentityKey(_ keyData: Data, forKey key: String) -> Bool
    func getIdentityKey(forKey key: String) -> Data?
    func deleteIdentityKey(forKey key: String) -> Bool
    func deleteAllKeychainData() -> Bool
    func secureClear(_ data: inout Data)
    func secureClear(_ string: inout String)
    func verifyIdentityKeyExists() -> Bool
    func save(key: String, data: Data, service: String, accessible: CFString?)
    func load(key: String, service: String) -> Data?
    func delete(key: String, service: String)
}

public final class KeychainManager: KeychainManagerProtocol {
    public init() {}

    public func saveIdentityKey(_ keyData: Data, forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "identity_\(key)",
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    public func getIdentityKey(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "identity_\(key)",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess else { return nil }
        return result as? Data
    }

    public func deleteIdentityKey(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "identity_\(key)"
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    public func deleteAllKeychainData() -> Bool { false }

    public func secureClear(_ data: inout Data) {
        _ = data.withUnsafeMutableBytes { memset_s($0.baseAddress, $0.count, 0, $0.count) }
        data = Data()
    }

    public func secureClear(_ string: inout String) {
        string = ""
    }

    public func verifyIdentityKeyExists() -> Bool {
        getIdentityKey(forKey: "noiseStaticKey") != nil
    }

    public func save(key: String, data: Data, service: String, accessible: CFString?) {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        if let accessible = accessible {
            query[kSecAttrAccessible as String] = accessible
        }
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    public func load(key: String, service: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess else { return nil }
        return result as? Data
    }

    public func delete(key: String, service: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - FavoritesPersistenceService stub
// In standalone mode, no mutual favorites exist.

@MainActor
final class FavoritesPersistenceService: ObservableObject {
    static let shared = FavoritesPersistenceService()
    @Published var mutualFavorites: [String] = []
    var hasAnyNostrFavorite: Bool { false }
    private init() {}
}

// MARK: - LocationChannelManager stub
// In standalone mode, location permission is not available.

enum PermissionState {
    case notDetermined, authorized, denied, restricted
}

@MainActor
final class LocationChannelManager: ObservableObject {
    static let shared = LocationChannelManager()
    @Published var permissionState: PermissionState = .notDetermined
    private init() {}
}

// MARK: - Tor stubs
// Only compiled when the Tor/Arti package is NOT available.

#if !canImport(Tor)
final class TorManager {
    static let shared = TorManager()
    private init() {}
    var isReady: Bool { true }
    var torEnforced: Bool { false }
    func awaitReady() async -> Bool { true }
    func isForeground() -> Bool { true }
}

final class TorURLSession {
    static let shared = TorURLSession()
    private init() {}
    var session: URLSession { .shared }
}

extension NSNotification.Name {
    static let TorDidBecomeReady = NSNotification.Name("TorDidBecomeReady")
}
#endif
