// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct DGImageCropper: View {
    
    let edgeColor: Color
    
    @StateObject var model: ImageCropperModel
    
    @State private var isShowingGrid: Bool = false
    
    public init(model: ImageCropperModel, edgeColor: Color = .white) {
        _model = .init(wrappedValue: model)
        self.edgeColor = edgeColor
    }
    
    public var body: some View {
        Image(uiImage: model.image)
            .resizable()
            .scaledToFit()
            .background(ViewGeometry())
            .onPreferenceChange(ViewSizeKey.self) { size in
                model.configure(size: size)
            }
            .overlay {
                ZStack {
                    Rectangle()
                        .fill(.black.opacity(0.5))
                    
                    Path { path in
                        let rect = CGRect(
                            x: model.rect.minX,
                            y: model.rect.minY,
                            width: model.rect.width,
                            height: model.rect.height
                        )
                        path.addRect(rect)
                    }
                    .blendMode(.destinationOut)
                }
                .compositingGroup()
            }
            .overlay {
                Path { path in
                    let rect = CGRect(
                        x: model.rect.minX + 3,
                        y: model.rect.minY + 3,
                        width: model.rect.width - 6,
                        height: model.rect.height - 6
                    )
                    path.addRect(rect)
                }
                .stroke(.white, lineWidth: 1)
                .contentShape(Rectangle())
                .gesture(gridDragGesture())
            }
            .overlay {
                Grid()
                    .frame(
                        width: max(model.rect.width - 6, 0),
                        height: max(model.rect.height - 6, 0)
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
    let model: ImageCropperModel = .init(image: .init(contentsOfFile: Bundle.module.path(forResource: "sample_image", ofType: "png")!)!)
    
    return DGImageCropper(
        model: model,
        edgeColor: .green
    )
}
