//
//  BodyAnchorARViewModel.swift
//  Vitato
//
//  Created by Melki Jonathan Andara on 16/06/25.
//

import SwiftUI
import ARKit

class BodyAnchorARViewModel: ObservableObject {
    @Published var tattooImage: UIImage? = UIImage(named: "tattoo1")
    @Published var tattooScale: Float = 0.15
    @Published var tattooOpacity: CGFloat = 0.9
    
    
    let arSessionManager = BodyAnchorARSessionManager()
    
    var arView: ARSCNView {
        arSessionManager.arView
    }
    
    init() {
        arSessionManager.tattooImage = tattooImage
        arSessionManager.tattooScale = tattooScale
        arSessionManager.tattooOpacity = tattooOpacity
    }
    
    func startARSession() {
        arSessionManager.startSession()
    }
    
    func pauseARSession() {
        arSessionManager.pauseSession()
    }
    
    func updateTattooImage(_ image: UIImage?) {
        tattooImage = image
        arSessionManager.tattooImage = image
        arSessionManager.updateAllTattoos()
    }
    
    func updateTattooScale(_ scale: Float) {
        tattooScale = scale
        arSessionManager.tattooScale = scale
        arSessionManager.updateAllTattoos()
    }
    
    func updateTattooOpacity(_ opacity: CGFloat) {
        tattooOpacity = opacity
        arSessionManager.tattooOpacity = opacity
        arSessionManager.updateAllTattoos()
    }
    
}
