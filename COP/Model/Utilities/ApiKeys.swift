//  ApiKeys.swift
//  COP
//  Created by Mac on 05/09/24.
//

import UIKit

struct ApiKeys{
    static let baseURL = KeychainHelper.shared.retrieve(for: Ud.baseURl) ?? ""
    static let baseURL2 = KeychainHelper.shared.retrieve(for: Ud.activeUserUrl) ?? ""
    static let locnUrl = KeychainHelper.shared.retrieve(for: Ud.locnUrl) ?? ""
}
