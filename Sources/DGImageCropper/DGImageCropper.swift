// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct DGImageCropper: View {
    
    let uiImage: UIImage
    let edgeColor: Color
    
    @StateObject var model: ImageCropperModel
    
    @State private var height: CGFloat = 1000
    
    public init(uiImage: UIImage, edgeColor: Color = .white) {
        self.uiImage = uiImage
        self.edgeColor = edgeColor
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
                    .stroke(.white, lineWidth: 1)
                }
                .overlay {
                    ZStack {
                        Edge(color: edgeColor)
                            .position(
                                x: model.topLeadingPoint.x + 10,
                                y: model.topLeadingPoint.y + 10
                            )
                    }
                }
        }
        .frame(height: height)
    }
}

#Preview {
    
    let url = Bundle.module.path(forResource: "sample_image", ofType: "png")!
    
    return DGImageCropper(uiImage: .init(contentsOfFile: url)!, edgeColor: Color(red: 0.03, green: 0.93, blue: 0.13))
        .preferredColorScheme(.dark)
}
