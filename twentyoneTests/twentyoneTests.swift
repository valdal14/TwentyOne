//
//  twentyoneTests.swift
//  twentyoneTests
//
//  Created by Valerio D'ALESSIO on 19/2/23.
//

import XCTest

@testable import twentyone

final class twentyoneTests: XCTestCase {

	//MARK: - Testing Model
    func testDeckModel() throws {
		let sut = DeckModel(id: UUID().uuidString, cards: [Card(url: URL(string: "https://deckofcardsapi.com/static/img/6H.png")!, value: "6"),
														   Card(url: URL(string: "https://deckofcardsapi.com/static/img/6H.png")!, value: "6"),
														   Card(url: URL(string: "https://deckofcardsapi.com/static/img/6H.png")!, value: "6"),
														   Card(url: URL(string: "https://deckofcardsapi.com/static/img/6H.png")!, value: "6")])
		XCTAssertEqual(sut.cards.count, 4)
    }
	
	func testCardValue() throws {
		
		let sut = DeckModel(id: UUID().uuidString, cards: [Card(url: URL(string: "https://deckofcardsapi.com/static/img/6H.png")!, value: "6"),
														   Card(url: URL(string: "https://deckofcardsapi.com/static/img/4H.png")!, value: "4"),
														   Card(url: URL(string: "https://deckofcardsapi.com/static/img/2H.png")!, value: "2"),
														   Card(url: URL(string: "https://deckofcardsapi.com/static/img/10H.png")!, value: "10")])
		
		let result = sut.cards.reduce(0, { $0 + (Int($1.value) ?? 0) })
		
		XCTAssertEqual(result, 22)
	}
	
	//MARK: - Testing Network Service
	func testDeckViewModelDecoding() async throws {
		let sut = NetworkService()
		let cards: [Card] = try await sut.getCards(isTest: true)
		XCTAssertEqual(cards.count, 52)
	}
	
	//MARK: - Testing Deck View Model
	func testComputedAceWithValueOne() async throws {
		let networkService = NetworkService()
		let sut = DeckViewModel(networkService: networkService)
		let cards: [Card] = try await networkService.getCards(isTest: true)
		await sut.setHandCount(cardValue: 20)
		let firstHandCount = await sut.getHandCount()
		
		let ace: Card = cards.filter { $0.value == "ACE"}.first!
		
		await sut.computeAce(cardValue: ace.value)
		
		Task.detached {
			let ace = await sut.getCurrentAceValue()
			XCTAssertEqual(ace, 1)
			XCTAssertEqual((ace + firstHandCount), 21)
		}
	}
	
	func testComputedAceWithValueEleven() async throws {
		let networkService = NetworkService()
		let sut = DeckViewModel(networkService: networkService)
		let cards: [Card] = try await networkService.getCards(isTest: true)
		await sut.setHandCount(cardValue: 8)
		let firstHandCount = await sut.getHandCount()
		
		let ace: Card = cards.filter { $0.value == "ACE"}.first!
		
		await sut.computeAce(cardValue: ace.value)
		
		Task.detached {
			let ace = await sut.getCurrentAceValue()
			XCTAssertEqual(ace, 11)
			XCTAssertEqual((ace + firstHandCount), 19)
		}
	}
	
	func testOutBoundReachedFalse() async throws {
		let sut = DeckViewModel(networkService: NetworkService())
		await sut.setHandCount(cardValue: 10)
		await sut.setHandCount(cardValue: 10)
		let passMaxValue = await sut.getBusted()
		
		XCTAssertEqual(passMaxValue, false)
	}

	func testOutBoundReachedTrue() async throws {
		let sut = DeckViewModel(networkService: NetworkService())
		await sut.setHandCount(cardValue: 10)
		await sut.setHandCount(cardValue: 10)
		await sut.setHandCount(cardValue: 10)
		let passMaxValue = await sut.getBusted()
		
		XCTAssertEqual(passMaxValue, true)
	}
	
	func testComputeCardValueFromNewDeck() async throws {
		let networkService = NetworkService()
		let sut = DeckViewModel(networkService: networkService)
		let cards: [Card] = try await networkService.getCards(isTest: true)
		
		var deckCardValues: [Int] = []
		
		for card in cards {
			deckCardValues.append(await sut.computeCardValue(cardValue: card.value))
		}
		
		let sum = deckCardValues.reduce(0, { $0 + $1 })
		XCTAssertTrue(sum == 340)
	}
	
	func testGenerateInGameDeckFromMock() async throws {
		let sut = DeckViewModel(networkService: NetworkService())
		try await sut.buildDeck(isTest: true)
		
		await sut.generateDeck()
		let currentDeck = await sut.getGeneratedInGameDeck()
		
		let sum = currentDeck.reduce(0, { $0 + $1.value })
		
		let aces = currentDeck.filter { $0.value == 1}
		
		XCTAssertTrue(sum == 340)
		XCTAssertEqual(aces.count, 4)
	}
	
	func testDealerAndPlayerHandsAndCurrentDeckSize() async throws {
		let sut = DeckViewModel(networkService: NetworkService())
		try await sut.buildDeck(isTest: true)
		
		await sut.generateDeck()
		
		let currentDeck = await sut.getGeneratedInGameDeck()
		
		/// assert current deck size
		XCTAssertTrue(currentDeck.count == 52)
		/// play a new hand
		let hand = await sut.playHand()
		XCTAssertTrue(hand.0.value >= 1)
		XCTAssertTrue(hand.1.value >= 1)
		/// assert new deck size
		let deckAfterFirstHand = await sut.getGeneratedInGameDeck()
		XCTAssertTrue(deckAfterFirstHand.count == 50)
	}
	
	func testDeckWasEmpty() async throws {
		let sut = DeckViewModel(networkService: NetworkService())
		try await sut.buildDeck(isTest: true)
		
		await sut.generateDeck()
		
		let currentDeck = await sut.getGeneratedInGameDeck()
		/// assert current deck size
		XCTAssertTrue(currentDeck.count == 52)
		
		for _ in 0..<26 {
			/// play a new hand
			let _ = await sut.playHand()
		}
		
		let deckAfter26Hands = await sut.getGeneratedInGameDeck()
		XCTAssertTrue(deckAfter26Hands.count == 0)
	}
	
	func testPlayerBusted() async throws {
		let sut = DeckViewModel(networkService: NetworkService())
		try await sut.buildDeck(isTest: true)
		
		await sut.generateDeck()
		
		for _ in 0..<8 {
			/// play a new hand
			let wasBusted = await sut.getBusted()
			if !wasBusted {
				let hand = await sut.playHand()
				await sut.setHandCount(cardValue: hand.1.value)
			} else {
				break
			}
		}
		
		let wasBusted = await sut.getBusted()

		XCTAssertTrue(wasBusted)
	}
}
