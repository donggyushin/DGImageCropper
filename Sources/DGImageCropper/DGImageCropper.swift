// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct DGImageCropper: View {
    
    let uiImage: UIImage
    
    @State private var height: CGFloat = 1000
    
    public init(uiImage: UIImage) {
        self.uiImage = uiImage
    }
    
    public var body: some View {
        GeometryReader { geo in
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .background(ViewGeometry())
                .onPreferenceChange(ViewSizeKey.self) { height in
                    self.height = height.height
                }
        }
        .frame(height: height)
    }
}

#Preview {
    
    let url = Bundle.module.path(forResource: "sample_image", ofType: "png")!
    
    return DGImageCropper(uiImage: .init(contentsOfFile: url)!)
        .preferredColorScheme(.dark)
}
