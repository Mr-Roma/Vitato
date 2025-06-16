//
//  BodyAnchorARView.swift
//  Vitato
//
//  Created by Melki Jonathan Andara on 16/06/25.
//

import SwiftUI

struct BodyAnchorARView: View {
    @StateObject private var viewModel = BodyAnchorARViewModel()
    
    @State private var isAnchorDetected: Bool = false // New state for anchor detection status
    
    var body: some View {
        ZStack {
            BodyAnchorARViewRepresentable(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                // New Text indicator for anchor detection
                Text(isAnchorDetected ? "Anchor Detected!" : "Looking for Anchor...")
                    .font(.headline)
                    .foregroundColor(isAnchorDetected ? .green : .red)
                    .padding(.top, 20)
                
                
          
            }
        }
        .onAppear {
            viewModel.startARSession()
        }
        .onDisappear {
            viewModel.pauseARSession()
        }
    }
}


#Preview {
    BodyAnchorARView()
}
