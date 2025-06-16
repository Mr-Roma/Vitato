//
//  ChooseBodyPartView.swift
//  Vitato
//
//  Created by Melki Jonathan Andara on 16/06/25.
//

import SwiftUI

struct ChooseBodyPartView: View {
    var body: some View {
        VStack{
            Text("Choose Body Part")
            
            HStack{
                NavigationLink(destination: ARContentView()){
                    VStack{
                        
                        Image(systemName: "face.smiling.inverse")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.black)
                        Text("Face")
                            .foregroundStyle(.black)
                    }
                    .frame(width: 100, height: 100)
                    .background(Color.orange)
                }
                
                NavigationLink(destination: BodyAnchorARView()){
                    VStack{
                        
                        Image(systemName: "figure.mind.and.body")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.black)
                        Text("Body")
                            .foregroundStyle(.black)
                    }
                    .frame(width: 100, height: 100)
                    .background(Color.orange)
                }
               
            }
        }
       
    }
}

#Preview {
    ChooseBodyPartView()
}
