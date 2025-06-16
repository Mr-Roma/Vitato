//
//  ARViewRepresentable.swift
//  TatoAnchor
//
//  Created by Romario Marcal on 14/06/25.
//

// Views/AR/ARViewRepresentable.swift
// Views/AR/ARViewRepresentable.swift
import SwiftUI
import ARKit

struct ARViewRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = viewModel.arSessionManager.arView
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Updates handled by ARSessionManager
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: ARViewRepresentable
        
        init(_ parent: ARViewRepresentable) {
            self.parent = parent
        }
    }
}
