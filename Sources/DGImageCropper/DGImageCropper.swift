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
                    edges
                }
        }
        .frame(height: height)
    }
    
    var edges: some View {
        ZStack {
            Edge(color: edgeColor)
                .position(
                    x: model.topLeadingPoint.x + 10,
                    y: model.topLeadingPoint.y + 10
                )
            
            Edge(color: edgeColor)
                .rotationEffect(.degrees(90))
                .position(
                    x: model.topTrailingPoint.x - 10,
                    y: model.topTrailingPoint.y + 10
                )
            
            Edge(color: edgeColor)
                .rotationEffect(.degrees(270))
                .position(
                    x: model.bottomLeadingPoint.x + 10,
                    y: model.bottomLeadingPoint.y - 10
                )
            
            Edge(color: edgeColor)
                .rotationEffect(.degrees(180))
                .position(
                    x: model.bottomTrailingPoint.x - 10,
                    y: model.bottomTrailingPoint.y - 10
                )
        }
    }
}

#Preview {
    
    let url = Bundle.module.path(forResource: "sample_image", ofType: "png")!
    
    return DGImageCropper(uiImage: .init(contentsOfFile: url)!, edgeColor: Color(red: 0.03, green: 0.93, blue: 0.13))
        .preferredColorScheme(.dark)
}
