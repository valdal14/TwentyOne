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
	
	//MARK: - Test Deck View Model
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
	
	func testSetHandCountForDealerAndPlayer() async throws {
		let sut = DeckViewModel(networkService: NetworkService())
		try await sut.buildDeck(isTest: true)
		
		await sut.generateDeck()
		
		await sut.setHandCount(cardValue: 10, player: sut.getPlayer())
		await sut.setHandCount(cardValue: 10, player: sut.getPlayer())
		await sut.setHandCount(cardValue: 8, player: sut.getDealer())
		await sut.setHandCount(cardValue: 8, player: sut.getDealer())
		
		let playerHandCount = await sut.player.getHandCount()
		let dealerHandCount = await sut.dealer.getHandCount()
		
		XCTAssertEqual(playerHandCount, 20)
		XCTAssertEqual(dealerHandCount, 16)
	}
	
	func testPlayFirstHand() async throws {
		let sut = DeckViewModel(networkService: NetworkService())
		try await sut.buildDeck(isTest: true)
		
		await sut.generateDeck()
		
		await sut.playFirstHand(player: sut.getPlayer(), dealder: sut.getDealer())
		
		let playerHandCount = await sut.player.getHandCount()
		let dealerHandCount = await sut.dealer.getHandCount()
		
		let playerGotBusted = await sut.player.getBusted()
		let dealerGotBusted = await sut.dealer.getBusted()
		
		XCTAssertTrue(playerGotBusted == false)
		XCTAssertTrue(dealerGotBusted == false)
		XCTAssertTrue(playerHandCount <= 21)
		XCTAssertTrue(dealerHandCount <= 21)
	}
	
	func testFirstHandBlackJack() async throws {
		
		let payload = """
{"success": true, "deck_id": "5ffa11tgchtw", "cards": [{"code": "0D", "image": "https://deckofcardsapi.com/static/img/AH.png", "value": "ACE", "suit": "DIAMONDS"}, {"code": "0C", "image": "https://deckofcardsapi.com/static/img/JS.png", "value": "10", "JACK": "CLUBS"}], "remaining": 50}
""".data(using: .utf8)
		
		let deck = try JSONDecoder().decode(DeckModel.self, from: payload!)
		let ace: Card = Card(url: deck.cards[0].url, value: deck.cards[0].value)
		let jack: Card = Card(url: deck.cards[1].url, value: deck.cards[1].value)
		
		let sut = DeckViewModel(networkService: NetworkService())
		try await sut.buildDeck(isTest: true)
		
		await sut.generateDeck()
		
		await sut.computeAce(cardValue: ace.value, player: sut.getPlayer())
		
		let gameCards: [GameCard] = [GameCard(url: ace.url, value: await sut.ace, isFaceUP: true),
									 GameCard(url: jack.url, value: Int(jack.value) ?? 0, isFaceUP: true)]
		
		let wasBlackJack = await sut.checkForBlackJack(cards: gameCards)
		
		XCTAssertTrue(wasBlackJack)
	}
	
	func testFirstHandBlackJackNotDone() async throws {
		
		let payload = """
{"success": true, "deck_id": "5ffa11tgchtw", "cards": [{"code": "0D", "image": "https://deckofcardsapi.com/static/img/AH.png", "value": "ACE", "suit": "DIAMONDS"}, {"code": "0C", "image": "https://deckofcardsapi.com/static/img/JS.png", "value": "7", "suit": "CLUBS"}], "remaining": 50}
""".data(using: .utf8)
		
		let deck = try JSONDecoder().decode(DeckModel.self, from: payload!)
		let ace: Card = Card(url: deck.cards[0].url, value: deck.cards[0].value)
		let seven: Card = Card(url: deck.cards[1].url, value: deck.cards[1].value)
		
		let sut = DeckViewModel(networkService: NetworkService())
		try await sut.buildDeck(isTest: true)
		
		await sut.generateDeck()
		
		await sut.computeAce(cardValue: ace.value, player: sut.getPlayer())
		
		let gameCards: [GameCard] = [GameCard(url: ace.url, value: await sut.ace, isFaceUP: true),
									 GameCard(url: seven.url, value: Int(seven.value) ?? 0, isFaceUP: true)]
		
		let wasBlackJack = await sut.checkForBlackJack(cards: gameCards)
		
		XCTAssertTrue(wasBlackJack == false)
	}
	
	//MARK: - Test Player View Model
	
	func testMoneyAmountWithNewBalanceZero() async throws {
		let sut = DeckViewModel(networkService: NetworkService())
		let _ = await sut.player.bet(amount: 1400)
		let currentBalance = await sut.player.getMoney()
		XCTAssertEqual(currentBalance, 0)
	}
	
	func testMoneyAmountWithNewBalance400() async throws {
		let sut = DeckViewModel(networkService: NetworkService())
		let _ = await sut.player.bet(amount: 1000)
		let currentBalance = await sut.player.getMoney()
		XCTAssertEqual(currentBalance, 400)
	}
	
	func testMoneyAmountWithNewBalanceInvalid() async throws {
		let sut = DeckViewModel(networkService: NetworkService())
		let status = await sut.player.bet(amount: 1410)
		let currentBalance = await sut.player.getMoney()
		XCTAssertEqual(status, false)
		XCTAssertEqual(currentBalance, 1400)
	}
	
	func testDrawingNewCard() async throws {
		let sut = DeckViewModel(networkService: NetworkService())
		try await sut.buildDeck(isTest: true)
		/// generate a new deck
		await sut.generateDeck()
		/// play the first hand
		await sut.playFirstHand(player: sut.getPlayer(), dealder: sut.getDealer())
		/// draw a new card if
		if await sut.getPlayer().getHandCount() == sut.getDealer().getHandCount() {
			let dealderCount = await sut.getDealer().getHandCount()
			let playerCount = await sut.getPlayer().getHandCount()
			print(dealderCount)
			print(playerCount)
			XCTAssertEqual(dealderCount, playerCount)
		}
		
		if await sut.getPlayer().getHandCount() < sut.getDealer().getHandCount() {
			await sut.drawNewCard(currentPlayer: sut.getPlayer())
			let playerCount = await sut.getPlayer().getHandCount()
			print(playerCount)
			let currentPlayerHand = await sut.getPlayerPlayedCards()
			XCTAssertTrue(currentPlayerHand.count == 3)
		}
		
		if await sut.getPlayer().getHandCount() > sut.getDealer().getHandCount() {
			await sut.drawNewCard(currentPlayer: sut.getDealer())
			let dealderCount = await sut.getDealer().getHandCount()
			print(dealderCount)
			let currentDealerHand = await sut.getDealerPlayedCards()
			XCTAssertTrue(currentDealerHand.count == 3)
		}
	}
}
