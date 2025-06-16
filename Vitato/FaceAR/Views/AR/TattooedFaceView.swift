//
//  TattooedFaceView.swift
//  TatoAnchor
//
//  Created by Romario Marcal on 14/06/25.
//

// Views/AR/TattooedFaceView.swift
import ARKit
import SceneKit

class TattooedFaceView: VirtualContentController {
    var contentNode: SCNNode?
    var tattooNode: SCNNode?
    var faceNode: SCNNode?
    
    
    var tattooImage: UIImage? {
        didSet { updateTattooMaterial() }
    }
    var tattooScale: Float = 0.15 {
        didSet { tattooNode?.scale = SCNVector3(tattooScale, tattooScale, tattooScale) }
    }
    var tattooOpacity: CGFloat = 0.9 {
        didSet { tattooNode?.opacity = tattooOpacity }
    }
    var placement: TattooPlacement = .cheek {
        didSet { updateTattooPosition() }
    }
    
    var relativePosition: SIMD3<Float> = SIMD3<Float>(0, 0, 0)
    var currentAnchorTransform: simd_float4x4?
    var currentFaceGeometry: ARFaceGeometry?
    var currentRotation: Float = 0

    
    func setupNode() -> SCNNode? {
        let parentNode = SCNNode()
        
        // Create face geometry (transparent)
        let faceGeometry = ARSCNFaceGeometry(device: MTLCreateSystemDefaultDevice()!)!
        faceGeometry.firstMaterial?.diffuse.contents = UIColor.clear
        faceNode = SCNNode(geometry: faceGeometry)
        parentNode.addChildNode(faceNode!)
        
        // Create tattoo node
        let plane = SCNPlane(width: 0.2, height: 0.2)
        plane.firstMaterial?.isDoubleSided = true
        plane.firstMaterial?.diffuse.contents = tattooImage
        plane.firstMaterial?.lightingModel = .constant
        
        tattooNode = SCNNode(geometry: plane)
        tattooNode?.scale = SCNVector3(tattooScale, tattooScale, tattooScale)
        tattooNode?.opacity = tattooOpacity
        
        parentNode.addChildNode(tattooNode!)
        contentNode = parentNode
        
        return contentNode
    }
    
    func update(with anchor: ARFaceAnchor) {
        guard let faceGeometry = faceNode?.geometry as? ARSCNFaceGeometry else { return }
        
        faceGeometry.update(from: anchor.geometry)
        currentAnchorTransform = anchor.transform
        currentFaceGeometry = anchor.geometry
        updateTattooPosition(faceGeometry: anchor.geometry, transform: anchor.transform)
    }
    
    private func updateTattooMaterial() {
        guard let tattooNode = tattooNode,
              let plane = tattooNode.geometry as? SCNPlane else { return }
        plane.firstMaterial?.diffuse.contents = tattooImage
    }
    
    private func updateTattooPosition() {
        if let geometry = currentFaceGeometry, let transform = currentAnchorTransform {
            updateTattooPosition(faceGeometry: geometry, transform: transform)
        }
    }
    
    private func updateTattooPosition(faceGeometry: ARFaceGeometry, transform: simd_float4x4) {
        guard let tattooNode = tattooNode, let contentNode = contentNode else { return }
        
        let vertexPosition = faceGeometry.vertices[placement.vertexIndex]
        let vertexHomogeneous = SIMD4<Float>(vertexPosition.x, vertexPosition.y, vertexPosition.z, 1)
        let transformedVertex = transform * vertexHomogeneous
        let worldVertex = SIMD3<Float>(transformedVertex.x, transformedVertex.y, transformedVertex.z)
        
        let localVertex = contentNode.simdConvertPosition(worldVertex, from: nil)
        let adjustedPosition = relativePosition + localVertex
        tattooNode.simdPosition = adjustedPosition + placement.offset
    }
    
    func updateTattooTransform(translation: SIMD3<Float>?, rotation: Float?, scale: Float?) {
        guard let tattooNode = tattooNode else { return }
        
        if let translation = translation {
            relativePosition += translation
        }
        
        if let rotation = rotation {
            let currentRotation = tattooNode.eulerAngles
            tattooNode.eulerAngles = SCNVector3(currentRotation.x, currentRotation.y, currentRotation.z + rotation)
        }
        
        if let scale = scale {
            tattooScale *= scale
            tattooNode.scale = SCNVector3(tattooScale, tattooScale, tattooScale)
        }
    }
}
