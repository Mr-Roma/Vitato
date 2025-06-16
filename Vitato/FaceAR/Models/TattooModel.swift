//
//  TattooModel.swift
//  TatoAnchor
//
//  Created by Romario Marcal on 14/06/25.
//

import ARKit

// Models/TattooModel.swift
import UIKit

struct TattooModel {
    let id = UUID()
    let image: UIImage
    var scale: Float
    var opacity: CGFloat
    var placement: TattooPlacement
}
