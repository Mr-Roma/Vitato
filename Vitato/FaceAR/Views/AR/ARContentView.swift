//
//  ARContentView.swift
//  TatoAnchor
//
//  Created by Romario Marcal on 14/06/25.
//

import SwiftUI

struct ARContentView: View {
    @StateObject private var viewModel = ARViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var adjustmentValue: Double = 0.5
    
    var body: some View {
        ZStack {
            // AR View
            ARViewRepresentable(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            // UI Overlay
            VStack(spacing: 0) {
                // Top navigation bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("AR FACE")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(UIColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 1.0)))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    // Empty space to balance the X button
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .background(Color.black.opacity(0.5))
                
                Spacer()
                
                // Bottom controls
                VStack(spacing: 16) {
                    // Slider
                    HStack {
                        // Change Design button
                        Button(action: {
                            viewModel.showTattooSelection.toggle()
                        }) {
                            VStack {
                                Image(systemName: "photo.stack")
                                    .font(.system(size: 24))
                                    .foregroundColor(.orange)
                                Text("CHANGE\nDESIGN")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: 80)
                        }
                        
                        Spacer()
                        
                        // Camera capture button
                        Button(action: {
                            viewModel.capturePhoto()
                        }) {
                            Circle()
                                .strokeBorder(Color.white, lineWidth: 3)
                                .background(Circle().fill(Color.white))
                                .frame(width: 70, height: 70)
                        }
                        
                        Spacer()
                        
                        // Switch Mode button
                        Button(action: {
                            // Switch mode action here
                        }) {
                            VStack {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.orange)
                                Text("SWITCH\nMODE")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: 80)
                        }
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.vertical, 16)
                .background(Color.black.opacity(0.7))
            }
            
            // Tattoo Selection Sheet
            if viewModel.showTattooSelection {
                VStack {
                    Spacer()
                    TattooSelectionView(viewModel: TattooSelectionViewModel()) { image in
                        viewModel.updateTattooImage(image)
                        viewModel.showTattooSelection = false
                    }
                    .frame(height: 300)
                    .background(Color.black.opacity(0.85))
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
        .animation(.spring(), value: viewModel.showTattooSelection)
        .onAppear {
            adjustmentValue = Double(viewModel.tattooOpacity)
            viewModel.startARSession()
        }
        .onDisappear {
            viewModel.pauseARSession()
        }
        .navigationBarHidden(true) // Hide the default navigation bar
        .statusBarHidden()
    }
}
