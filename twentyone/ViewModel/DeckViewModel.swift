//
//  DeckViewModel.swift
//  twentyone
//
//  Created by Valerio D'ALESSIO on 19/2/23.
//

import Foundation

enum AceValue: Int {
	case one = 1
	case eleven = 11
}

actor DeckViewModel: ObservableObject {
	private let networkService: NetworkService
	
	@Published private(set) var gameDeck: [GameCard] = []
	@Published private(set) var ace: Int = 0
	@Published private(set) var handCount: Int = 0
	@Published private(set) var busted: Bool = false
	private let maxHandCount: Int = 21
	private(set) var deck: [Card] = []
	
	init(networkService: NetworkService){
		self.networkService = networkService
	}
	
	/// Get cards from NetworkService and populate the cards mutable variable
	func buildDeck(isTest: Bool) async throws {
		if isTest {
			deck = try await networkService.getCards(isTest: isTest)
		} else {
			deck = try await networkService.getCards(isTest: isTest)
		}
	}
	
	/// Compute the mutable property ace based on the mutable property handCount
	///
	/// parameters - cardValue: String
	func computeAce(cardValue: String) {
		if cardValue == "ACE" && handCount <= 10 {
			ace = 11
		} else {
			ace = 1
		}
	}
	
	/// Given a cardValue in String returns its game value in Int
	///
	/// returns: - Int
	func computeCardValue(cardValue: String) -> Int {
		if cardValue == "QUEEN" || cardValue == "JACK" || cardValue == "KING" {
			return 10
		} else if cardValue == "ACE" {
			return 1
		} else {
			return Int(cardValue) ?? 0
		}
	}
	
	/// Generate the in-game deck
	func generateDeck() {
		for card in deck {
			gameDeck.append(GameCard(url: card.url, value: computeCardValue(cardValue: card.value)))
		}
	}
	
	/// Return the gameDeck
	///
	/// returns: - [GameCard]
	func getGeneratedInGameDeck() -> [GameCard] {
		return gameDeck
	}
	
	/// Returns the value of the current ace
	///
	/// returns: - Int
	func getCurrentAceValue() -> Int {
		return self.ace
	}
	
	/// change the internal state of the mutable variable handCount
	func setHandCount(cardValue: Int) {
		if handCount + cardValue <= self.maxHandCount {
			handCount += cardValue
		} else {
			busted.toggle()
		}
		
	}
	
	/// Returns the value of the mutable property handCount
	///
	/// returns: - Int
	func getHandCount() -> Int {
		return handCount
	}
	
	/// Returns the current value of the mutable property outboundReached
	///
	/// returns: - Bool
	func getBusted() -> Bool {
		return busted
	}
	
	/// Shuffle the current deck
	func shuffleDeck() {
		deck.shuffle()
	}
	
	/// Return a tuple made of Dealer and Player cards hande
	///
	/// returns: - (GameCard, GameCard)
	func playHand() -> (GameCard, GameCard) {
		let dealerIndex = Int.random(in: 0..<gameDeck.count)
		let delearCard = gameDeck.remove(at: dealerIndex)
		
		let playerIndex = Int.random(in: 0..<gameDeck.count)
		let playerCard = gameDeck.remove(at: playerIndex)
		
		return (delearCard, playerCard)
	}
	
}
