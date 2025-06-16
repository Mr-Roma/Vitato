// TattooSelectionView.swift
import SwiftUI
import PhotosUI

struct TattooSelectionView: View {
    @ObservedObject var viewModel: TattooSelectionViewModel
    var onTattooSelected: (UIImage) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Recommended Designs Section
                Section(header:
                    Text("Recommended Designs")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                ) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(viewModel.recommendedTattoos, id: \.self) { tattoo in
                                Image(uiImage: tattoo)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .padding(5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(viewModel.selectedTattoo == tattoo ? Color.blue : Color.clear, lineWidth: 3)
                                    )
                                    .onTapGesture {
                                        viewModel.selectedTattoo = tattoo
                                        onTattooSelected(tattoo)
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Custom Upload Section
                Section(header:
                    Text("Upload Your Design")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                ) {
                    VStack(spacing: 15) {
                        // Photos Picker
                        PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                            Label("Choose from Library", systemImage: "photo")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                        }
                        .onChange(of: viewModel.selectedItem) { newItem in
                            Task {
                                viewModel.selectedItem = newItem
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    viewModel.removeBackground(from: image) { result in
                                        if let result = result {
                                            viewModel.selectedTattoo = result
                                            onTattooSelected(result)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Camera Button
                        Button {
                            viewModel.showCamera = true
                        } label: {
                            Label("Take Photo", systemImage: "camera")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                        }
                        .sheet(isPresented: $viewModel.showCamera) {
                            ImagePicker(sourceType: .camera) { image in
                                viewModel.removeBackground(from: image) { result in
                                    if let result = result {
                                        viewModel.selectedTattoo = result
                                        onTattooSelected(result)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                if viewModel.isProcessingImage {
                    VStack {
                        ProgressView("Removing background...")
                        Text("This may take a few seconds")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            .padding(.vertical)
        }
    }
}
