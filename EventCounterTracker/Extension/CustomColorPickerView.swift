//
//  CustomColorPickerView.swift
//  EventCounterTracker
//
//  Created by Andre Made on 9/23/25.
//

import SwiftUI

struct CustomColorPickerView: View {
    @Binding var selectedColor: Color
    private let colors: [Color] = [
        .red, .blue, .green, .purple, .orange
    ]
    private let columns = [
           GridItem(.adaptive(minimum: 50))
       ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, content: {
                ForEach(colors, id: \.self) { color in
                    ZStack {
                        Circle()
                            .foregroundStyle(color)
                            .frame(width: 50, height: 50)
                        
                        if color == selectedColor {
                            Image(systemName: "checkmark")
                                .font(.largeTitle)
                                .foregroundStyle(.white)
                        }
                    }
                    .animation(.linear(duration: 1), value: selectedColor)
                    .onTapGesture {
                        selectedColor = color
                    }
                }
            })
        }
        
    }
}

#Preview {
    CustomColorPickerView(selectedColor: .constant(.blue))
}
