//
//  TattooPlacement.swift
//  TatoAnchor
//
//  Created by Romario Marcal on 14/06/25.
//

// Models/TattooPlacement.swift (unchanged from your original)
import Foundation

enum TattooPlacement: String, CaseIterable, Identifiable {
    case cheek = "Cheek"
    case forehead = "Forehead"
    case chin = "Chin"
    case jawline = "Jawline"
    case neck = "Neck"
    
    var id: String { self.rawValue }
    
    var vertexIndex: Int {
        switch self {
        case .cheek: return 1068
        case .forehead: return 1024
        case .chin: return 10
        case .jawline: return 650
        case .neck: return 150
        }
    }
    
    var offset: SIMD3<Float> {
        switch self {
        case .cheek: return SIMD3<Float>(0, 0, 0.005)
        case .forehead: return SIMD3<Float>(0, 0.02, 0.01)
        case .chin: return SIMD3<Float>(0, -0.01, 0.005)
        case .jawline: return SIMD3<Float>(0, -0.005, 0.005)
        case .neck: return SIMD3<Float>(0, -0.03, 0.01)
        }
    }
}
