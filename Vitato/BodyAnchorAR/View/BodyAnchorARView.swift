//
//  BodyAnchorARView.swift
//  Vitato
//
//  Created by Melki Jonathan Andara on 16/06/25.
//

import SwiftUI

struct BodyAnchorARView: View {
    
    @State private var isAnchorDetected: Bool = false // New state for anchor detection status
    
    //camera
    @State private var isCameraButtonClicked: Bool = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        ZStack {
           BodyAnchorARViewRepresentable(
                frame: UIScreen.main.bounds,
                onAnchorDetectionChange: { detected in // Pass the closure
                    isAnchorDetected = detected
                }
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                Text(isAnchorDetected ? "Anchor Detected!" : "Looking for Anchor...")
                    .font(.headline)
                    .foregroundColor(isAnchorDetected ? .green : .red)
                    .padding(.top, 20)
            }
        }
    }
}


#Preview {
    BodyAnchorARView()
}
