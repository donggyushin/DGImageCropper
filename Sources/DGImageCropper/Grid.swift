//
//  File.swift
//  DGImageCropper
//
//  Created by 신동규 on 9/13/24.
//

import SwiftUI

struct Grid: View {
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                horizontalLine()
                Spacer()
                horizontalLine()
                Spacer()
            }
            
            HStack {
                Spacer()
                verticalLine()
                Spacer()
                verticalLine()
                Spacer()
            }
        }
    }
    
    func horizontalLine() -> some View {
        Rectangle()
            .fill(.white.opacity(0.5))
            .frame(height: 1)
    }
    
    func verticalLine() -> some View {
        Rectangle()
            .fill(.white.opacity(0.5))
            .frame(width: 1)
    }
}

#Preview {
    Grid()
        .preferredColorScheme(.dark)
}
