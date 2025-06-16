//
//  BodyAnchorARViewModel.swift
//  Vitato
//
//  Created by Melki Jonathan Andara on 16/06/25.
//

import SwiftUI

class BodyAnchorARViewModel: ObservableObject {
    @Published var tattooImage: UIImage? = UIImage(named: "tattoo1")
    @Published var tattooScale: Float = 0.15
    @Published var tattooOpacity: CGFloat = 0.9
    
    
}
