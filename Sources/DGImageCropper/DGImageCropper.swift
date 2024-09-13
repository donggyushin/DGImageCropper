// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct DGImageCropper: View {
    
    let edgeColor: Color
    
    @StateObject var model: ImageCropperModel
    
    @State private var height: CGFloat = 1000
    @State private var isShowingGrid: Bool = false
    
    public init(model: ImageCropperModel, edgeColor: Color = .white) {
        _model = .init(wrappedValue: model)
        self.edgeColor = edgeColor
    }
    
    public var body: some View {
        GeometryReader { geo in
            Image(uiImage: model.image)
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
                    .contentShape(Rectangle())
                    .gesture(gridDragGesture())
                }
                .overlay {
                    Grid()
                        .frame(
                            width: model.rect.width,
                            height: model.rect.height
                        )
                        .position(
                            x: model.rect.midX - 3,
                            y: model.rect.midY - 3
                        )
                        .padding(3)
                        .opacity(isShowingGrid ? 1 : 0)
                        .animation(.default, value: isShowingGrid)
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
                    x: model.topLeadingPoint.x + 10.5,
                    y: model.topLeadingPoint.y + 10.5
                )
                .gesture(dragGesture(edge: .topLeadingPoint))
            
            Edge(color: edgeColor)
                .rotationEffect(.degrees(90))
                .position(
                    x: model.topTrailingPoint.x - 10.5,
                    y: model.topTrailingPoint.y + 10.5
                )
                .gesture(dragGesture(edge: .topTrailingPoint))
            
            Edge(color: edgeColor)
                .rotationEffect(.degrees(270))
                .position(
                    x: model.bottomLeadingPoint.x + 10.5,
                    y: model.bottomLeadingPoint.y - 10.5
                )
                .gesture(dragGesture(edge: .bottomLeadingPoint))
            
            Edge(color: edgeColor)
                .rotationEffect(.degrees(180))
                .position(
                    x: model.bottomTrailingPoint.x - 10.5,
                    y: model.bottomTrailingPoint.y - 10.5
                )
                .gesture(dragGesture(edge: .bottomTrailingPoint))
        }
    }
    
    func dragGesture(edge: ImageCropperModel.EdgePosition) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if isShowingGrid == false {
                    isShowingGrid = true
                }
                model.dragEdge(size: value.translation, edge: edge)
            }
            .onEnded { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isShowingGrid = false
                }
                model.updatePreviousRef()
            }
    }
    
    func gridDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                if isShowingGrid == false {
                    isShowingGrid = true
                }
                model.move(size: value.translation)
            }
            .onEnded { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isShowingGrid = false
                }
                model.updatePreviousRef()
            }
    }
}

#Preview {
    return DGImageCropper(
        model: .init(image: .init(contentsOfFile: Bundle.module.path(forResource: "sample_image", ofType: "png")!)!),
        edgeColor: .green
    )
    .preferredColorScheme(.dark)
}
