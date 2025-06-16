//
//  VirtualContentController.swift
//  TatoAnchor
//
//  Created by Romario Marcal on 14/06/25.
//

// Models/VirtualContentController.swift (updated protocol)
import ARKit
import SceneKit

protocol VirtualContentController {
    var contentNode: SCNNode? { get set }
    func update(with anchor: ARFaceAnchor)
    func setupNode() -> SCNNode?
    func updateTattooTransform(translation: SIMD3<Float>?, rotation: Float?, scale: Float?)
}
