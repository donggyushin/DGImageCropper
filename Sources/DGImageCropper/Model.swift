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
    
    @Published var isShowingGrid: Bool = false
    
    private var previousTopLeadingPoint: CGPoint = .zero
    private var previousTopTrailingPoint: CGPoint = .zero
    private var previousBottomLeadingPoint: CGPoint = .zero
    private var previousBottomTrailingPoint: CGPoint = .zero
    
    private var originRect: CGRect = .zero
    
    private let minDiff: CGFloat = 100
    
    init() {
        bind()
    }
    
    func configure(size: CGSize) {
        topLeadingPoint = .init(x: 0, y: 0)
        topTrailingPoint = .init(x: size.width, y: 0)
        bottomLeadingPoint = .init(x: 0, y: size.height)
        bottomTrailingPoint = .init(x: size.width, y: size.height)
        
        updatePreviousRef()
        
        originRect = GenerateRectUseCase(point1: topLeadingPoint, point2: bottomTrailingPoint).execute()
    }
    
    func dragEdge(size: CGSize, edge: EdgePosition) {
        switch edge {
        case .topLeadingPoint:
            let value = (size.width + size.height) / 2
            let topLeadingPoint = CGPoint(x: previousTopLeadingPoint.x + value, y: previousTopLeadingPoint.y + value)
            let topTrailingPoint = CGPoint(x: previousTopTrailingPoint.x, y: previousTopTrailingPoint.y + value)
            let bottomLeadingPoint = CGPoint(x: previousBottomLeadingPoint.x + value, y: previousBottomLeadingPoint.y)
            
            guard topLeadingPoint.x >= 0 && topLeadingPoint.y >= 0 else { return }
            
            if CheckDraggableUseCase(point1: topLeadingPoint, point2: bottomTrailingPoint, minDiff: minDiff).execute() {
                self.topLeadingPoint = topLeadingPoint
                self.topTrailingPoint = topTrailingPoint
                self.bottomLeadingPoint = bottomLeadingPoint
            }
            
        case .topTrailingPoint:
            let value = (size.width - size.height) / 2
            topTrailingPoint = CGPoint(x: previousTopTrailingPoint.x + value, y: previousTopTrailingPoint.y - value)
            topLeadingPoint = CGPoint(x: previousTopLeadingPoint.x, y: previousTopLeadingPoint.y - value)
            bottomTrailingPoint = CGPoint(x: previousBottomTrailingPoint.x + value, y: previousBottomTrailingPoint.y)
        case .bottomLeadingPoint:
            let value = (size.width - size.height) / 2
            bottomLeadingPoint = CGPoint(x: previousBottomLeadingPoint.x + value, y: previousBottomLeadingPoint.y - value)
            topLeadingPoint = CGPoint(x: previousTopLeadingPoint.x + value, y: previousTopLeadingPoint.y)
            bottomTrailingPoint = CGPoint(x: previousBottomTrailingPoint.x, y: previousBottomTrailingPoint.y - value)
        case .bottomTrailingPoint:
            let value = (size.width + size.height) / 2
            bottomTrailingPoint = CGPoint(x: previousBottomTrailingPoint.x + value, y: previousBottomTrailingPoint.y + value)
            bottomLeadingPoint = CGPoint(x: previousBottomLeadingPoint.x, y: previousBottomLeadingPoint.y + value)
            topTrailingPoint = CGPoint(x: previousTopTrailingPoint.x + value, y: previousTopTrailingPoint.y)
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
