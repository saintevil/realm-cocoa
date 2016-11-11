////////////////////////////////////////////////////////////////////////////
//
// Copyright 2016 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import Realm
import Realm.Private
import Foundation

/**
 An object representing a Realm Object Server user.

 - see: `RLMSyncUser`
 */
public typealias SyncUser = RLMSyncUser

/**
 A singleton which configures and manages the Realm Object Server synchronization-related functionality.

 - see: `RLMSyncManager`
 */
public typealias SyncManager = RLMSyncManager

extension SyncManager {
#if swift(>=3.0)
    /// The sole instance of the singleton.
    public static var shared: SyncManager {
        return __shared()
    }
#else
    /// The sole instance of the singleton.
    @nonobjc public static func sharedManager() -> SyncManager {
        return __sharedManager()
    }
#endif
}

/**
 A session object which represents communication between the client and server for a specific Realm.

 - see: `RLMSyncSession`
 */
public typealias SyncSession = RLMSyncSession

/**
 A closure type for a closure which can be set on the `SyncManager` to allow errors to be reported to the application.

 - see: `RLMSyncErrorReportingBlock`
 */
public typealias ErrorReportingBlock = RLMSyncErrorReportingBlock

/**
 A closure type for a closure which is used by certain APIs to asynchronously return a `User` object to the application.

 - see: `RLMUserCompletionBlock`
 */
public typealias UserCompletionBlock = RLMUserCompletionBlock

/**
 An error associated with the SDK's synchronization functionality.

 - see: `RLMSyncError`
 */
public typealias SyncError = RLMSyncError

/**
 An enum which can be used to specify the level of logging.

 - see: `RLMSyncLogLevel`
 */
public typealias SyncLogLevel = RLMSyncLogLevel

#if swift(>=3.0)

/**
 A data type whose values represent different authentication providers that can be used with the Realm Object Server.

 - see: `RLMIdentityProvider`
 */
public typealias Provider = RLMIdentityProvider

/// A `SyncConfiguration` represents configuration parameters for Realms intended to sync with a Realm Object Server.
public struct SyncConfiguration {
    /// The `SyncUser` who owns the Realm that this configuration should open.
    public let user: SyncUser

    /**
     The URL of the Realm on the Realm Object Server that this configuration should open.

     - warning: The URL must be absolute (e.g. `realms://example.com/~/foo`), and cannot end with
                `.realm`, `.realm.lock` or `.realm.management`.
     */
    public let realmURL: URL

    /// A policy that determines what should happen when all references to Realms opened by this configuration
    /// go out of scope.
    internal let stopPolicy: RLMSyncStopPolicy

    internal init(config: RLMSyncConfiguration) {
        self.user = config.user
        self.realmURL = config.realmURL
        self.stopPolicy = config.stopPolicy
    }

    func asConfig() -> RLMSyncConfiguration {
        let config = RLMSyncConfiguration(user: user, realmURL: realmURL)
        config.stopPolicy = stopPolicy
        return config
    }

    /**
     Initialize a sync configuration with a user and a Realm URL.

     - warning: The URL must be absolute (e.g. `realms://example.com/~/foo`), and cannot end with
                `.realm`, `.realm.lock` or `.realm.management`.
     */
    public init(user: SyncUser, realmURL: URL) {
        self.user = user
        self.realmURL = realmURL
        self.stopPolicy = .afterChangesUploaded
    }
}

/// A `SyncCredentials` represents data that uniquely identifies a Realm Object Server user.
public struct SyncCredentials {
    public typealias Token = String

    internal var token: Token
    internal var provider: Provider
    internal var userInfo: [String: Any]

    /// Initialize new credentials using a custom token, authentication provider, and user information dictionary. In
    /// most cases, the convenience initializers should be used instead.
    public init(customToken token: Token, provider: Provider, userInfo: [String: Any] = [:]) {
        self.token = token
        self.provider = provider
        self.userInfo = userInfo
    }

    private init(_ credentials: RLMSyncCredentials) {
        self.token = credentials.token
        self.provider = credentials.provider
        self.userInfo = credentials.userInfo
    }

    /// Initialize new credentials using a Facebook account token.
    public static func facebook(token: Token) -> SyncCredentials {
        return SyncCredentials(RLMSyncCredentials(facebookToken: token))
    }

    /// Initialize new credentials using a Google account token.
    public static func google(token: Token) -> SyncCredentials {
        return SyncCredentials(RLMSyncCredentials(googleToken: token))
    }

    /// Initialize new credentials using an iCloud account token.
    public static func iCloud(token: Token) -> SyncCredentials {
        return SyncCredentials(RLMSyncCredentials(iCloudToken: token))
    }

    /// Initialize new credentials using a Realm Object Server username and password.
    public static func usernamePassword(username: String,
                                        password: String,
                                        register: Bool = false) -> SyncCredentials {
        return SyncCredentials(RLMSyncCredentials(username: username, password: password, register: register))
    }

    /// Initialize new credentials using a Realm Object Server access token.
    public static func accessToken(_ accessToken: String, identity: String) -> SyncCredentials {
        return SyncCredentials(RLMSyncCredentials(accessToken: accessToken, identity: identity))
    }
}

extension RLMSyncCredentials {
    fileprivate convenience init(_ credentials: SyncCredentials) {
        self.init(customToken: credentials.token, provider: credentials.provider, userInfo: credentials.userInfo)
    }
}

extension SyncUser {
    /// Given credentials and a server URL, log in a user and asynchronously return a `SyncUser` object which can be used to
    /// open Realms and Sessions.
    public static func logIn(with credentials: SyncCredentials,
                             server authServerURL: URL,
                             timeout: TimeInterval = 30,
                             onCompletion completion: @escaping UserCompletionBlock) {
        return SyncUser.__logIn(with: RLMSyncCredentials(credentials),
                                authServerURL: authServerURL,
                                timeout: timeout,
                                onCompletion: completion)
    }

    /// An array of all valid, logged-in users.
    public static var all: [SyncUser] {
        return __allUsers()
    }

    /**
     The logged-in user. `nil` if none exists.

     - warning: Throws an Objective-C exception if more than one logged-in user exists.
     */
    public static var current: SyncUser? {
        return __current()
    }
}

#else

/**
 A data type whose values represent different authentication providers that can be used with the Realm Object Server.

 - see: `RLMIdentityProvider`
 */
public typealias Provider = String // `RLMIdentityProvider` imports as `NSString`

/// A `SyncConfiguration` represents configuration parameters for Realms intended to sync with a Realm Object Server.
public struct SyncConfiguration {
    /// The `SyncUser` who owns the Realm that this configuration should open.
    public let user: SyncUser

    /**
     The URL of the Realm on the Realm Object Server that this configuration should open.

     - warning: The URL must be absolute (e.g. `realms://example.com/~/foo`), and cannot end with
                `.realm`, `.realm.lock` or `.realm.management`.
     */
    public let realmURL: NSURL

    /// A policy that determines what should happen when all references to Realms opened by this configuration
    /// go out of scope.
    internal let stopPolicy: RLMSyncStopPolicy

    internal init(config: RLMSyncConfiguration) {
        self.user = config.user
        self.realmURL = config.realmURL
        self.stopPolicy = config.stopPolicy
    }

    func asConfig() -> RLMSyncConfiguration {
        let config = RLMSyncConfiguration(user: user, realmURL: realmURL)
        config.stopPolicy = stopPolicy
        return config
    }

    /**
     Initialize a sync configuration with a user and a Realm URL.

     - warning: The URL must be absolute (e.g. `realms://example.com/~/foo`), and cannot end with
                `.realm`, `.realm.lock` or `.realm.management`.
     */
    public init(user: SyncUser, realmURL: NSURL) {
        self.user = user
        self.realmURL = realmURL
        self.stopPolicy = .AfterChangesUploaded
    }
}

/// A `SyncCredentials` represents data that uniquely identifies a Realm Object Server user.
public struct SyncCredentials {
    public typealias Token = String

    internal var token: Token
    internal var provider: Provider
    internal var userInfo: [String: AnyObject]

    // swiftlint:disable valid_docs

    /// Initialize new credentials using a custom token, authentication provider, and user information dictionary. In
    /// most cases, the convenience initializers should be used instead.
    public init(customToken token: Token, provider: Provider, userInfo: [String: AnyObject] = [:]) {
        self.token = token
        self.provider = provider
        self.userInfo = userInfo
    }

    private init(_ credentials: RLMSyncCredentials) {
        self.token = credentials.token
        self.provider = credentials.provider
        self.userInfo = credentials.userInfo
    }

    /// Initialize new credentials using a Facebook account token.
    public static func facebook(token: Token) -> SyncCredentials {
        return SyncCredentials(RLMSyncCredentials(facebookToken: token))
    }

    /// Initialize new credentials using a Google account token.
    public static func google(token: Token) -> SyncCredentials {
        return SyncCredentials(RLMSyncCredentials(googleToken: token))
    }

    /// Initialize new credentials using an iCloud account token.
    public static func iCloud(token: Token) -> SyncCredentials {
        return SyncCredentials(RLMSyncCredentials(ICloudToken: token))
    }

    /// Initialize new credentials using a Realm Object Server username and password.
    public static func usernamePassword(username: String,
                                        password: String,
                                        register: Bool = false) -> SyncCredentials {
        return SyncCredentials(RLMSyncCredentials(username: username, password: password, register: register))
    }

    /// Initialize new credentials using a Realm Object Server access token.
    public static func accessToken(accessToken: String, identity: String) -> SyncCredentials {
        return SyncCredentials(RLMSyncCredentials(accessToken: accessToken, identity: identity))
    }
}

extension RLMSyncCredentials {
    private convenience init(_ credentials: SyncCredentials) {
        self.init(customToken: credentials.token, provider: credentials.provider, userInfo: credentials.userInfo)
    }
}

extension SyncUser {
    /// Given credentials and a server URL, log in a user and asynchronously return a `SyncUser` object which can be used to
    /// open Realms and Sessions.
    public static func logInWithCredentials(credentials: SyncCredentials,
                                            authServerURL: NSURL,
                                            timeout: NSTimeInterval = 30,
                                            onCompletion completion: UserCompletionBlock) {
        return __logInWithCredentials(RLMSyncCredentials(credentials),
                                      authServerURL: authServerURL,
                                      timeout: timeout,
                                      onCompletion: completion)
    }

    /// An array of all valid, logged-in users.
    @nonobjc public static func allUsers() -> [SyncUser] {
        return __allUsers()
    }

    /**
     The logged-in user. `nil` if none exists.

     - warning: Throws an Objective-C exception if more than one logged-in user exists.
     */
    @nonobjc public static func currentUser() -> SyncUser? {
        return __currentUser()
    }
}

#endif
