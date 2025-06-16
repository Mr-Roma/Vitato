//
//  BodyAnchorARSessionManager.swift
//  Vitato
//
//  Created by Melki Jonathan Andara on 16/06/25.
//
import ARKit
import RealityKit
import SwiftUI
import Combine

class BodyAnchorARSessionManager: NSObject, ObservableObject,  UIGestureRecognizerDelegate{
    var arView = ARSCNView()
   
    // Add missing properties
    private var scene: SCNScene {
        return arView.scene
    }
    
    var onAnchorDetectionChange: ((Bool) -> Void)?
    
    // Gesture recognizers
    private var panGesture: UIPanGestureRecognizer!
    private var pinchGesture: UIPinchGestureRecognizer!
    private var rotationGesture: UIRotationGestureRecognizer!
    
    @Published var tattooImage: UIImage? = UIImage(named: "tattoo1")
    @Published var tattooScale: Float = 0.15
    @Published var tattooOpacity: CGFloat = 0.9
    
    
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
        // Set up image tracking
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing AR Reference Images")
        }
        
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1
        configuration.isLightEstimationEnabled = true
        
        // Start the session with the configuration
        arView.session.run(configuration)
        
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
    
    private func handlePlaceTattoo() {
        // Find the ARImageAnchor that represents the detected "anchor" image
        guard let imageAnchor = arView.session.currentFrame?.anchors.first(where: { $0 is ARImageAnchor }) as? ARImageAnchor,
              let tattooImage = tattooImage else {
            print("No AR Image Anchor detected or tattoo image is missing.")
            return
        }
        
        // Remove any existing anchors/entities from the scene to replace them with the new tattoo
        scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
        
        // Get the physical size of the detected reference image
        let physicalWidth = Float(imageAnchor.referenceImage.physicalSize.width)
        let physicalHeight = Float(imageAnchor.referenceImage.physicalSize.height)
        
        // Create a plane mesh with the dimensions of the physical image
        let plane = SCNPlane(width: CGFloat(physicalWidth), height: CGFloat(physicalHeight))
        
        // Create material with the tattoo image
        let material = SCNMaterial()
        material.diffuse.contents = tattooImage
        material.isDoubleSided = true
        plane.materials = [material]
        
        let node = SCNNode(geometry: plane)
        node.eulerAngles.x = -.pi / 2 // Rotate to lie flat
        
        // Add the node to the scene
        scene.rootNode.addChildNode(node)
        print("Tattoo placed on detected anchor image.")
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
         
         gesture.setTranslation(.zero, in: arView)
     }
     
     @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
         guard gesture.state == .changed else { return }
         
         let scale = Float(gesture.scale)

         
         gesture.scale = 1.0
     }
     
     @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
         guard gesture.state == .changed else { return }
         
         let rotation = Float(gesture.rotation)
 
         
         gesture.rotation = 0
     }
     
     // MARK: - Gesture Recognizer Delegate
     func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
         return true
     }
     
    
    func updateAllTattoos() {
        
    }
}

extension BodyAnchorARSessionManager: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Handle updated anchors
        if let imageAnchor = anchor as? ARImageAnchor {
            // Update AR content position if needed
            if imageAnchor.isTracked {
                self.handlePlaceTattoo()
                print("Anchor image is being tracked")
                onAnchorDetectionChange?(true)
            } else {
                onAnchorDetectionChange?(false)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
    
    }
}
