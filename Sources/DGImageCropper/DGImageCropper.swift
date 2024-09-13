// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct DGImageCropper: View {
    
    let uiImage: UIImage
    
    public init(uiImage: UIImage) {
        self.uiImage = uiImage
    }
    
    public var body: some View {
        Text("Text")
    }
}

#Preview {
    
    let url = Bundle.module.path(forResource: "sample_image", ofType: "png")!
    
    return DGImageCropper(uiImage: .init(contentsOfFile: url)!)
        .preferredColorScheme(.dark)
}
