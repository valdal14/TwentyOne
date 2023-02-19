//
//  TwentyOne.swift
//  twentyone
//
//  Created by Valerio D'ALESSIO on 19/2/23.
//

import SwiftUI

struct TwentyOne: View {
    var body: some View {
		ZStack {
			Image("table")
				.resizable()
				.scaledToFill()
		}
		.edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TwentyOne()
    }
}
