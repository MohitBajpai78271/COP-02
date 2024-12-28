//
//  LocationOfUser.swift
//  COP
//
//  Created by Mac on 25/07/24.
//

import Foundation

struct LocationOfUser: Codable {
    let id: String
    let userId: String
    let phoneNumber: String?
    let latitude: Double?
    let longitude: Double?
    let timestamp: String
    let v: Int
    var name: String?        // Add this property
    var startTime: String?   // Add this property
    var endTime: String?     // Add this property

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId
        case phoneNumber
        case latitude
        case longitude
        case timestamp
        case v = "__v"
        case name         // Add this mapping
        case startTime    // Add this mapping
        case endTime      // Add this mapping
    }
}

