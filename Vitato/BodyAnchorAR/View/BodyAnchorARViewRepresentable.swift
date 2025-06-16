//
//  AnchorARViewRepresentable.swift
//  Vitato
//
//  Created by Melki Jonathan Andara on 16/06/25.
//

import SwiftUI
import ARKit

struct BodyAnchorARViewRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: BodyAnchorARViewModel
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = viewModel.arSessionManager.arView
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Updates handled by ARSessionManager
    }
}

