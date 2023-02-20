//
//  DeckModel.swift
//  twentyone
//
//  Created by Valerio D'ALESSIO on 19/2/23.
//

import Foundation

struct DeckModel: Decodable, Sendable, Identifiable {
	let id: String
	let cards: [Card]
	
	enum CodingKeys: String, CodingKey {
		case id = "deck_id"
		case cards
	}
}

struct Card: Decodable, Sendable {
	let url: URL
	var value: String
	
	enum CodingKeys: String, CodingKey {
		case url = "image"
		case value
	}
}

struct GameCard: Sendable {
	let url: URL
	var value: Int
}
