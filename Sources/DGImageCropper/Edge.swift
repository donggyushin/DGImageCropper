//
//  File.swift
//  DGImageCropper
//
//  Created by 신동규 on 9/13/24.
//

import SwiftUI

struct Edge: View {
    
    let color: Color
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(color)
                .frame(height: 2)
            
            Spacer()
        }
        .frame(width: 20, height: 20)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(color)
                .frame(width: 2)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    Edge(color: .red)
}
