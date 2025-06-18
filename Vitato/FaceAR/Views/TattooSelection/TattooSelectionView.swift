//
//  TattooSelectionView.swift
//  TatoAnchor
//
//  Created by Romario Marcal on 14/06/25.
//

import SwiftUI
import PhotosUI

struct TattooSelectionView: View {
    @ObservedObject var viewModel: TattooSelectionViewModel
    var onTattooSelected: (UIImage?) -> Void
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Select Tattoo")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    viewModel.showImagePicker = true
                }) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                
                Button(action: {
                    viewModel.showCamera = true
                }) {
                    Image(systemName: "camera")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(0..<viewModel.recommendedTattoos.count, id: \.self) { index in
                        Button(action: {
                            onTattooSelected(viewModel.recommendedTattoos[index])
                        }) {
                            Image(uiImage: viewModel.recommendedTattoos[index])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 80)
                                .background(Color.black)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            
            // Placement selection
            PlacementSelectionView { placement in
                // Add code to update the placement
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $viewModel.showImagePicker) {
            PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                Text("Select Photo")
            }
            .onChange(of: viewModel.selectedItem) { newItem in
                if let newItem = newItem {
                    newItem.loadTransferable(type: Data.self) { result in
                        switch result {
                        case .success(let data):
                            if let data = data, let uiImage = UIImage(data: data) {
                                viewModel.removeBackground(from: uiImage) { processedImage in
                                    onTattooSelected(processedImage ?? uiImage)
                                }
                            }
                        case .failure:
                            break
                        }
                    }
                }
            }
        }
        .overlay(
            viewModel.isProcessingImage ?
                ZStack {
                    Color.black.opacity(0.6)
                    ProgressView("Processing...")
                        .foregroundColor(.white)
                }
                : nil
        )
    }
}

struct PlacementSelectionView: View {
    @State private var selectedPlacement: TattooPlacement = .cheek
    var onPlacementSelected: (TattooPlacement) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Placement")
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.bottom, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TattooPlacement.allCases) { placement in
                        PlacementButton(
                            label: placement.rawValue,
                            isSelected: selectedPlacement == placement,
                            action: {
                                selectedPlacement = placement
                                onPlacementSelected(placement)
                            }
                        )
                    }
                }
            }
        }
    }
}

struct PlacementButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.orange : Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(16)
        }
    }
}
