//
//  PlayerHeaderView.swift
//  twentyone
//
//  Created by Valerio D'ALESSIO on 20/2/23.
//

import SwiftUI

struct PlayerHeaderView: View {
	@Binding var total: Double
	@Binding var currentScore: Int
	@State private var didBet: Bool = true
	@State private var didBetFinished: Bool = false
	
	var body: some View {
		VStack {
			HStack {
				Button {
					didBet.toggle()
					didBetFinished.toggle()
				} label: {
					Text("BET")
				}
				.disabled(didBetFinished)
				.buttonStyle(.borderedProminent)
				Button {
					//
				} label: {
					Text("STAND")
				}
				.disabled(didBet)
				.buttonStyle(.borderedProminent)
				Button {
					//
				} label: {
					Text("DRAW")
				}
				.disabled(didBet)
				.buttonStyle(.borderedProminent)
			}
			.padding()
			HStack {
				Image("dealerFishes")
					.resizable()
					.scaledToFit()
					.frame(width: 50, height: 50)
				Text(String(format: "%.1f", total))
					.font(.title)
					.fontWeight(.bold)
					.foregroundColor(.white)
				Spacer()
				Text("Hand: \(currentScore)")
					.font(.title)
					.fontWeight(.bold)
					.foregroundColor(.white)
			}
		}
		.padding()
	}
}

struct PlayerHeaderView_Previews: PreviewProvider {
	@State static var total: Double = 1400
	@State static var currentScore: Int = 14
    static var previews: some View {
		PlayerHeaderView(total: $total, currentScore: $currentScore)
    }
}
