//
//  HomeView.swift
//  Vitato
//
//  Created by Melki Jonathan Andara on 16/06/25.
//

import SwiftUI


struct HomeView: View {
    var body: some View {
        NavigationStack{
            VStack{
                Text("Ini Home")
                NavigationLink(destination: ChooseBodyPartView()){
                    VStack{
                        Text("Choose body")
                    }
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                      
                        
                    
                }
                
            }
        }
        
        
    }
}

#Preview {
    HomeView()
}
