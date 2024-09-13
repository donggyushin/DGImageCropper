//
//  File.swift
//  DGImageCropper
//
//  Created by 신동규 on 9/13/24.
//

import Combine
import Foundation

@MainActor
public final class ImageCropperModel: ObservableObject {
    
    enum EdgePosition {
        case topLeadingPoint
        case topTrailingPoint
        case bottomLeadingPoint
        case bottomTrailingPoint
    }
    
    @Published var topLeadingPoint: CGPoint = .zero
    @Published var topTrailingPoint: CGPoint = .zero
    @Published var bottomLeadingPoint: CGPoint = .zero
    @Published var bottomTrailingPoint: CGPoint = .zero
    
    @Published var rect: CGRect = .zero
    
    private var previousTopLeadingPoint: CGPoint = .zero
    private var previousTopTrailingPoint: CGPoint = .zero
    private var previousBottomLeadingPoint: CGPoint = .zero
    private var previousBottomTrailingPoint: CGPoint = .zero
    
    init() {
        bind()
    }
    
    func configure(size: CGSize) {
        topLeadingPoint = .init(x: 0, y: 0)
        topTrailingPoint = .init(x: size.width, y: 0)
        bottomLeadingPoint = .init(x: 0, y: size.height)
        bottomTrailingPoint = .init(x: size.width, y: size.height)
        
        updatePreviousRef()
    }
    
    func dragEdge(size: CGSize, edge: EdgePosition) {
        let value = (size.width + size.height) / 2
        
        if edge == .topLeadingPoint {
            topLeadingPoint = CGPoint(x: previousTopLeadingPoint.x + value, y: previousTopLeadingPoint.y + value)
            topTrailingPoint = CGPoint(x: previousTopTrailingPoint.x, y: previousTopTrailingPoint.y + value)
            bottomLeadingPoint = CGPoint(x: previousBottomLeadingPoint.x + value, y: previousBottomLeadingPoint.y)
        }
    }
    
    func updatePreviousRef() {
        previousTopLeadingPoint = topLeadingPoint
        previousTopTrailingPoint = topTrailingPoint
        previousBottomLeadingPoint = bottomLeadingPoint
        previousBottomTrailingPoint = bottomTrailingPoint
    }
    
    private func bind() {
        $topLeadingPoint
            .combineLatest($bottomTrailingPoint)
            .map({ point1, point2 in
                var point1 = point1
                var point2 = point2
                point1 = .init(x: point1.x + 3, y: point1.y + 3)
                point2 = .init(x: point2.x - 3, y: point2.y - 3)
                return (point1, point2)
            })
            .map({ GenerateRectUseCase(point1: $0.0, point2: $0.1) })
            .map({ $0.execute() })
            .assign(to: &$rect)
    }
}
