//
//  File.swift
//  
//
//  Created by Le Quang Tuan Cuong(CuongLQT) on 26/01/2024.
//

import Foundation

struct Constants {    
    // IdentityServer config
    static let IdentityClientIdHeader = "client_id"
    static let IdentityClientIdValue = "crooti"
    static let IdentityClientSecretHeader = "client_secret"
    static let IdentityClientSecretValue = "secret"
    static let IdentityGrantTypeHeader = "grant_type"
    static let IdentityGrantTypeValue = "custom"
    static let IdentityGrantTypeRefreshValue = "refresh_token"
    static let IdentityScopeHeader = "scope"
    static let IdentityScopeValue = "crooti_api offline_access"
    static let IdentityRefreshHeader = "refresh_token"
}
