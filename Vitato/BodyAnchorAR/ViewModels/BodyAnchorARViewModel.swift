//
//  BodyAnchorARViewModel.swift
//  Vitato
//
//  Created by Melki Jonathan Andara on 16/06/25.
//

import ARKit
import RealityKit
import SwiftUI
import Combine

class BodyAnchorARViewModel: ARView {
    var onAnchorDetectionChange: ((Bool) -> Void)?
    private var isTrackingAnchor = false
    
    // Gesture recognizers
    private var panGesture: UIPanGestureRecognizer!
    private var pinchGesture: UIPinchGestureRecognizer!
    private var rotationGesture: UIRotationGestureRecognizer!
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        setupAR()
        setupGestures()
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAR() {

        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing AR Reference Images")
        }

        let config = ARImageTrackingConfiguration()
        config.trackingImages = referenceImages
        config.maximumNumberOfTrackedImages = 1
        config.isLightEstimationEnabled = true
        
        session.run(config)
        
        session.delegate = self
    }
    
    private func setupGestures() {

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
        
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinchGesture.delegate = self
        self.addGestureRecognizer(pinchGesture)
        
        rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        rotationGesture.delegate = self
        self.addGestureRecognizer(rotationGesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {

        guard gesture.state == .changed,
              let entity = scene.anchors.first?.children.first as? ModelEntity else { return }
        
        let translation = gesture.translation(in: self)
        let scaleFactor: Float = 0.001
        let translation3D = SIMD3<Float>(
            Float(translation.x) * scaleFactor,
            Float(-translation.y) * scaleFactor,
            0
        )
        
        entity.position += translation3D
        gesture.setTranslation(.zero, in: self)
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard gesture.state == .changed,
              let entity = scene.anchors.first?.children.first as? ModelEntity else { return }
        
        let scale = Float(gesture.scale)
        
        entity.scale *= scale
        gesture.scale = 1.0
    }
    
    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard gesture.state == .changed,
              let entity = scene.anchors.first?.children.first as? ModelEntity else { return }
        
        let rotation = Float(gesture.rotation)
        
        let rotationQuaternion = simd_quatf(angle: rotation, axis: [0, 0, 1])
        
        entity.orientation *= rotationQuaternion
        gesture.rotation = 0
    }
    
    private func handlePlaceTattoo() {
        guard let tattooImage = UIImage(named: "tattoo1") else {
            print("No tattoo image selected")
            return
        }
        
        guard let imageAnchor = session.currentFrame?.anchors.first(where: { $0 is ARImageAnchor }) as? ARImageAnchor else {
            print("No ARImageAnchor detected. Please point camera at the anchor image.")
            return
        }
        
        scene.anchors.removeAll()
        
        let physicalWidth = Float(imageAnchor.referenceImage.physicalSize.width)
        let physicalHeight = Float(imageAnchor.referenceImage.physicalSize.height)
        
        let plane = MeshResource.generatePlane(width: physicalWidth, height: physicalHeight)
        
        if let cgImage = tattooImage.cgImage,
           let texture = try? TextureResource.init(image: cgImage, options: .init(semantic: .color)) {
            
            var material = SimpleMaterial()
            material.baseColor = .texture(texture)
            
            let entity = ModelEntity(mesh: plane, materials: [material])
            
            entity.orientation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])
            
            entity.position = SIMD3(0, 0.001, 0)
            
            let anchor = AnchorEntity(anchor: imageAnchor)
            
            anchor.addChild(entity)
            scene.addAnchor(anchor)
        } else {
            print("Failed to create texture from tattoo image")
        }
    }
}

extension BodyAnchorARViewModel: ARSessionDelegate {
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor {
               
                self.handlePlaceTattoo()
                
                print("Detected anchor image: \(imageAnchor.referenceImage.name ?? "unnamed")")
                onAnchorDetectionChange?(true)
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {

        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor {
                isTrackingAnchor = imageAnchor.isTracked
                
                if imageAnchor.isTracked {
                    
                    onAnchorDetectionChange?(true)
                } else {
                    onAnchorDetectionChange?(false)
                }
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("AR Session failed: \(error.localizedDescription)")
        isTrackingAnchor = false
        onAnchorDetectionChange?(false)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("AR Session was interrupted")
        isTrackingAnchor = false
        onAnchorDetectionChange?(false)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("AR Session interruption ended")
        // Restart the session
        setupAR()
    }
}

