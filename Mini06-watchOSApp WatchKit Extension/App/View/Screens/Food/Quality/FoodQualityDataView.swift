//
//  FoodQualityDataView.swift
//  Mini06-watchOSApp WatchKit Extension
//
//  Created by Vitor Souza on 15/06/22.
//

import SwiftUI

struct FoodQualityDataView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedScreen: DataCollectingFlowView.DataCollectingFlowScreens
    
    var body: some View {
        GeometryReader { metrics in
            ZStack {
                VStack {
                    HStack(spacing: 0) {
                        Text("O que comeu hoje?")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(Color.white)
                        
                        Spacer()
                        
                        Button {
                            // TODO: Help button action
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .resizable()
                                .frame(width: .width(18, from: metrics),
                                       height: .width(18, from: metrics))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.borderless)
                        .hidden()
                    }
                    .padding(.bottom, .width(10, from: metrics))
                    
                    ScrollView {
                        ForEach(FoodQualityDataModel.data) { dataModel in
                            FoodQualityRowView(
                                imageName: dataModel.image,
                                title: dataModel.name,
                                metrics: metrics
                            ) { selected in
                                // TODO: put selected data model into a array for passing data to following view
                            }
                        }
                        
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 0.0, height: .width(50, from: metrics))
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        RoundedSquareButton(metrics: metrics) {
                            if let nextScreen = selectedScreen.next() {
                                withAnimation(.easeInOut(duration: 0.6)) {
                                    selectedScreen = nextScreen
                                }
                            } else {
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Qualidade")
    }
}

struct FoodQualityDataView_Previews: PreviewProvider {
    static var previews: some View {
        FoodQualityDataView(selectedScreen: .constant(.foodQuantity))
    }
}