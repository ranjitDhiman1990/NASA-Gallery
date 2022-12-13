//
//  MediaModel.swift
//  NASA Gallery
//
//  Created by Dhiman Ranjit on 09/12/22.
//

import Foundation


struct MediaModel: Decodable {
    let copyright: String?
    let date: String?
    let explanation: String?
    let hdurl: String?
    let media_type: String?
    let service_version: String?
    let title: String?
    let url: String?
}


enum JSONParseError: Error {
    case fileNotFound
    case dataInitialisation(error: Error)
    case decoding(error: Error)
}

extension Decodable {
    static func from(localJSON filename: String,
                     bundle: Bundle = .main) -> Result<Self, JSONParseError> {
        guard let url = bundle.url(forResource: filename, withExtension: "json") else {
            return .failure(.fileNotFound)
        }
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch let error {
            return .failure(.dataInitialisation(error: error))
        }

        do {
            return .success(try JSONDecoder().decode(self, from: data))
        } catch let error {
            return .failure(.decoding(error: error))
        }
    }
}
