//
//  AnchorARViewRepresentable.swift
//  Vitato
//
//  Created by Melki Jonathan Andara on 16/06/25.
//

import SwiftUI
import ARKit

struct BodyAnchorARViewRepresentable: UIViewRepresentable {
    var frame: CGRect = UIScreen.main.bounds
    var onAnchorDetectionChange: ((Bool) -> Void)?
 
    func makeUIView(context: Context) -> BodyAnchorARViewModel {
        let arView = BodyAnchorARViewModel(frame: frame)
        arView.onAnchorDetectionChange = onAnchorDetectionChange
        return arView
    }
    
    func updateUIView(_ uiView: BodyAnchorARViewModel, context: Context) { }
}

