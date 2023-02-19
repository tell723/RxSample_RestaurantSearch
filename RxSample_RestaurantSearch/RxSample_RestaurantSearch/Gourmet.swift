//
//  Gourmet.swift
//  RxSample_RestaurantSearch
//
//  Created by t-watanabe on 2023/02/19.
//

import Foundation

struct Gourmet: Codable {
    let results: Results

    struct Results: Codable {
        let api_version: String
        let shop: [Shop]

        struct Shop: Codable {
            let name: String
        }
    }
}

