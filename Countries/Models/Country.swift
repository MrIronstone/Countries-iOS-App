//
//  Country.swift
//  Countries
//
//  Created by admin on 30.09.2022.
//

import Foundation

struct CountriesResponse: Codable {
    let links: [Link]
    let data: [Country]
}

struct Country: Codable {
    let name: String?
    let code: String?
    let wikiDataId: String?
}

struct Link: Codable {
    let rel: String?
    let href: String?
}
