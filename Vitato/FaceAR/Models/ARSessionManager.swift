//
//  ARSessionManager.swift
//  TatoAnchor
//
//  Created by Romario Marcal on 14/06/25.
//

import ARKit
import SceneKit

class ARSessionManager: NSObject, ObservableObject,  UIGestureRecognizerDelegate{
    var arView = ARSCNView()
    private var faceAnchorsAndContent: [ARFaceAnchor: TattooedFaceView] = [:]
    
    // Gesture recognizers
      private var panGesture: UIPanGestureRecognizer!
      private var pinchGesture: UIPinchGestureRecognizer!
      private var rotationGesture: UIRotationGestureRecognizer!
    
    @Published var tattooImage: UIImage? = UIImage(named: "tattoo1")
    @Published var tattooScale: Float = 0.15
    @Published var tattooOpacity: CGFloat = 0.9
    @Published var placement: TattooPlacement = .cheek
    
    override init() {
        super.init()
        setupARView()
        setupGestureRecognizers()
    }
    
    private func setupARView() {
        arView.delegate = self
        arView.automaticallyUpdatesLighting = true
    }
    
    func startSession() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    self.arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                }
            }
        }
    }
    
    func pauseSession() {
        arView.session.pause()
    }
    
    private func setupGestureRecognizers() {
         panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
         panGesture.delegate = self
         arView.addGestureRecognizer(panGesture)
         
         pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
         pinchGesture.delegate = self
         arView.addGestureRecognizer(pinchGesture)
         
         rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
         rotationGesture.delegate = self
         arView.addGestureRecognizer(rotationGesture)
     }
     
     @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
         guard gesture.state == .changed else { return }
         
         let translation = gesture.translation(in: arView)
         let scaleFactor: Float = 0.001
         let translation3D = SIMD3<Float>(
             Float(translation.x) * scaleFactor,
             Float(-translation.y) * scaleFactor,
             0
         )
         
         for content in faceAnchorsAndContent.values {
             content.updateTattooTransform(translation: translation3D, rotation: nil, scale: nil)
         }
         
         gesture.setTranslation(.zero, in: arView)
     }
     
     @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
         guard gesture.state == .changed else { return }
         
         let scale = Float(gesture.scale)
         for content in faceAnchorsAndContent.values {
             content.updateTattooTransform(translation: nil, rotation: nil, scale: scale)
         }
         
         gesture.scale = 1.0
     }
     
     @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
         guard gesture.state == .changed else { return }
         
         let rotation = Float(gesture.rotation)
         for content in faceAnchorsAndContent.values {
             content.updateTattooTransform(translation: nil, rotation: rotation, scale: nil)
         }
         
         gesture.rotation = 0
     }
     
     // MARK: - Gesture Recognizer Delegate
     func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
         return true
     }
     
    
    func updateAllTattoos() {
        for (anchor, content) in faceAnchorsAndContent {
            content.tattooImage = tattooImage
            content.tattooScale = tattooScale
            content.tattooOpacity = tattooOpacity
            content.placement = placement
            content.update(with: anchor)
        }
    }
}

extension ARSessionManager: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard anchor is ARFaceAnchor else { return nil }
        
        let content = TattooedFaceView()
        content.tattooImage = tattooImage
        content.tattooScale = tattooScale
        content.tattooOpacity = tattooOpacity
        content.placement = placement
        
        if let node = content.setupNode() {
            faceAnchorsAndContent[anchor as! ARFaceAnchor] = content
            return node
        }
        
        return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let content = faceAnchorsAndContent[faceAnchor] else { return }
        content.update(with: faceAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        faceAnchorsAndContent.removeValue(forKey: faceAnchor)
    }
}
