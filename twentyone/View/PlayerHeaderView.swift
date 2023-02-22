//
//  PlayerHeaderView.swift
//  twentyone
//
//  Created by Valerio D'ALESSIO on 20/2/23.
//

import SwiftUI

struct PlayerHeaderView: View {
	@EnvironmentObject var deckVM: DeckViewModel
	
	@State private var totalMoney: Double = 0
	
	@State private var didBet: Bool = true
	@State private var didBetFinished: Bool = true
	@State private var currentBet: Double = 0.0
	@State private var playerCabBet100: Bool = true
	@State private var playerCabBet200: Bool = true
	@State private var playerCabBet500: Bool = true
	
	var body: some View {
		VStack {
			HStack(spacing: 30) {
				Image(playerCabBet100 ? "Fish-100" : "")
					.resizable()
					.scaledToFit()
					.frame(width: 70, height: 70)
					.opacity(didBet ? 0.5 : 1.0)
					.disabled(playerCabBet100)
					.onTapGesture {
						Task {
							if await deckVM.player.bet(amount: 100) {
								currentBet = 100
								didBetFinished.toggle()
							} else {
								playerCabBet100 = false
							}
						}
					}
				Image(playerCabBet200 ? "Fish-200" : "")
					.resizable()
					.scaledToFit()
					.frame(width: 70, height: 70)
					.opacity(didBet ? 0.5 : 1.0)
					.onTapGesture {
						Task {
							if await deckVM.player.bet(amount: 200) {
								currentBet = 200
								didBetFinished.toggle()
							} else {
								playerCabBet200 = false
							}
						}
					}
				Image(playerCabBet500 ? "Fish-500" : "")
					.resizable()
					.scaledToFit()
					.frame(width: 70, height: 70)
					.opacity(didBet ? 0.5 : 1.0)
					.onTapGesture {
						Task {
							if await deckVM.player.bet(amount: 500) {
								currentBet = 500
								didBetFinished.toggle()
							} else {
								playerCabBet500 = false
							}
						}
					}
			}
			.disabled(didBet)
			.padding()
			HStack {
				Button {
					didBet.toggle()
				} label: {
					Text("BET")
				}
				.buttonStyle(.borderedProminent)
				Button {
					Task {
						await deckVM.playerDecidedToStand(playerBet: currentBet)
						totalMoney = await deckVM.player.getMoney()
					}
				} label: {
					Text("STAND")
				}
				.disabled(didBetFinished)
				.buttonStyle(.borderedProminent)
				Button {
					Task {
						await deckVM.playerDecidedToHit(playerBet: currentBet)
						totalMoney = await deckVM.player.getMoney()
					}
				} label: {
					Text("DRAW")
				}
				.disabled(didBetFinished)
				.buttonStyle(.borderedProminent)
			}
			.padding()
			HStack {
				Image("dealerFishes")
					.resizable()
					.scaledToFit()
					.frame(width: 50, height: 50)
				Text(String(format: "%.1f", totalMoney))
					.font(.title)
					.fontWeight(.bold)
					.foregroundColor(.white)
				Text("player")
					.font(.title)
					.fontWeight(.bold)
					.foregroundColor(.white)
			}
		}
		.onAppear {
			Task {
				totalMoney = await deckVM.player.getMoney()
			}
		}
		.padding()
	}
}

struct PlayerHeaderView_Previews: PreviewProvider {
	@State static var total: Double = 1400
    static var previews: some View {
		PlayerHeaderView()
    }
}
