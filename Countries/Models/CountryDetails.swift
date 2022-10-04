//
//  CountryDetails.swift
//  Countries
//
//  Created by admin on 4.10.2022.
//

import Foundation

struct CountryDetailsResponse: Codable {
    let data: CountryDetails
}

struct CountryDetails: Codable {
let capital: String?
let code: String?
let callingCode: String?
let flagImageUri: String?
let name: String?
let numRegions: Int?
let wikiDataId: String?
}
