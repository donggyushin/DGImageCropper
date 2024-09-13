// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct DGImageCropper: View {
    
    let uiImage: UIImage
    
    @StateObject var model: ImageCropperModel
    
    @State private var height: CGFloat = 1000
    
    public init(uiImage: UIImage) {
        self.uiImage = uiImage
        _model = .init(wrappedValue: .init())
    }
    
    public var body: some View {
        GeometryReader { geo in
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .background(ViewGeometry())
                .onPreferenceChange(ViewSizeKey.self) { size in
                    self.height = size.height
                    model.configure(size: size)
                }
                .overlay {
                    Path { path in
                        path.addRect(model.rect)
                    }
                    .stroke(lineWidth: 2)
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
