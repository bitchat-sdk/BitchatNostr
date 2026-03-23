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
#endif
