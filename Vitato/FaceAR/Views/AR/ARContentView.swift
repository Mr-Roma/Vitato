//
//  ARContentView.swift
//  TatoAnchor
//
//  Created by Romario Marcal on 14/06/25.
//

// Views/AR/ARContentView.swift
import SwiftUI

struct ARContentView: View {
    @StateObject private var viewModel = ARViewModel()
    
    var body: some View {
        ZStack {
            ARViewRepresentable(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Button {
                    viewModel.showTattooSelection.toggle()
                } label: {
                    Image(systemName: "paintbrush.pointed")
                        .font(.system(size: 24))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding(.top)
                
                if viewModel.showTattooSelection {
                    TattooSelectionView(viewModel: TattooSelectionViewModel()) { image in
                        viewModel.updateTattooImage(image)
                    }
                    .frame(height: 300)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .animation(.spring(), value: viewModel.showTattooSelection)
        .onAppear {
            viewModel.startARSession()
        }
        .onDisappear {
            viewModel.pauseARSession()
        }
    }
}
