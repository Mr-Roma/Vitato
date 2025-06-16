//
//  ARViewModel.swift
//  TatoAnchor
//
//  Created by Romario Marcal on 14/06/25.
//

// ViewModels/ARViewModel.swift
import SwiftUI
import ARKit

class ARViewModel: ObservableObject {
    @Published var tattooImage: UIImage? = UIImage(named: "tattoo1")
    @Published var tattooScale: Float = 0.15
    @Published var tattooOpacity: CGFloat = 0.9
    @Published var selectedPlacement: TattooPlacement = .cheek
    @Published var showTattooSelection = false
    
    
    
    let arSessionManager = ARSessionManager()
    
    var arView: ARSCNView {
        arSessionManager.arView
    }
    
    init() {
        arSessionManager.tattooImage = tattooImage
        arSessionManager.tattooScale = tattooScale
        arSessionManager.tattooOpacity = tattooOpacity
        arSessionManager.placement = selectedPlacement
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
    
    func updatePlacement(_ placement: TattooPlacement) {
        selectedPlacement = placement
        arSessionManager.placement = placement
        arSessionManager.updateAllTattoos()
    }
}

// ViewModels/TattooSelectionViewModel.swift (same as previous)
