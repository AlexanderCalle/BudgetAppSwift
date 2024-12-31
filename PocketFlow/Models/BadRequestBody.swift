//
//  BadRequestBody.swift
//  smart_budget
//
//  Created by Alexander Callebaut on 26/11/2024.
//

import Foundation

struct ErrorDetail: Codable {
    let property: String
    let message: String
}

/// Enum to handle different message formats
enum DecodedMessage: Codable {
    case detailed([ErrorDetail], String, Int) // For the detailed error format
    case simple(String)                      // For the simple error format

    enum CodingKeys: String, CodingKey {
        case message
        case error
        case statusCode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Check if `message` is an array
        if let errorDetails = try? container.decode([ErrorDetail].self, forKey: .message),
           let error = try? container.decode(String.self, forKey: .error),
           let statusCode = try? container.decode(Int.self, forKey: .statusCode) {
            self = .detailed(errorDetails, error, statusCode)
        } else if let errorMessage = try? container.decode(String.self, forKey: .message) {
            self = .simple(errorMessage)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath, debugDescription: "Unknown JSON format"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .detailed(let errorDetails, let error, let statusCode):
            try container.encode(errorDetails, forKey: .message)
            try container.encode(error, forKey: .error)
            try container.encode(statusCode, forKey: .statusCode)
        case .simple(let errorMessage):
            try container.encode(errorMessage, forKey: .message)
        }
    }
    
    /// Returns a user-friendly string representation of the error.
    func errorMessage() -> String {
        switch self {
        case .detailed(let errorDetails, let error, let statusCode):
            let detailsString = errorDetails.map { "\($0.property): \($0.message)" }.joined(separator: ", ")
            return "Error \(statusCode): \(error) (\(detailsString))"
        case .simple(let errorMessage):
            return errorMessage
        }
    }
}
