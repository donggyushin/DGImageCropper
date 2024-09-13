//
//  File.swift
//  DGImageCropper
//
//  Created by 신동규 on 9/13/24.
//

import Combine
import Foundation
import UIKit

@MainActor
public final class ImageCropperModel: ObservableObject {
    
    public enum CropRatio {
        case square
    }
    
    enum EdgePosition {
        case topLeadingPoint
        case topTrailingPoint
        case bottomLeadingPoint
        case bottomTrailingPoint
    }
    
    let image: UIImage
    
    @Published var topLeadingPoint: CGPoint = .zero
    @Published var topTrailingPoint: CGPoint = .zero
    @Published var bottomLeadingPoint: CGPoint = .zero
    @Published var bottomTrailingPoint: CGPoint = .zero
    
    @Published var rect: CGRect = .zero
    
    @Published var ratio: CropRatio = .square
    
    private var previousTopLeadingPoint: CGPoint = .zero
    private var previousTopTrailingPoint: CGPoint = .zero
    private var previousBottomLeadingPoint: CGPoint = .zero
    private var previousBottomTrailingPoint: CGPoint = .zero
    
    private var originRect: CGRect = .zero
    
    private let minDiff: CGFloat = 100
    
    public init(image: UIImage) {
        self.image = image
        bind()
    }
    
    public func crop() -> UIImage? {
        cropImage(image: image, imageSizeInScreen: originRect.size, rect: rect)
    }
    
    public func changeRatio(ratio: CropRatio) {
        switch ratio {
        case .square:
            topLeadingPoint = .init(x: originRect.minX, y: originRect.minY)
            topTrailingPoint = .init(x: originRect.maxX, y: originRect.minY)
            bottomLeadingPoint = .init(x: originRect.minX, y: originRect.maxY)
            bottomTrailingPoint = .init(x: originRect.maxX, y: originRect.maxY)
            updatePreviousRef()
        }
    }
    
    func configure(size: CGSize) {
        originRect = GenerateRectUseCase(
            point1: .init(x: 0, y: 0),
            point2: .init(x: size.width, y: size.height)
        ).execute()
        changeRatio(ratio: ratio)
    }
    
    func move(size: CGSize) {
        if CheckMoveableRectUseCase(originRect: originRect, rect: GenerateRectUseCase(point1: previousTopLeadingPoint, point2: previousBottomTrailingPoint).execute(), move: size).execute() {
            let x = size.width
            let y = size.height
            
            let topLeadingPoint = CGPoint(x: previousTopLeadingPoint.x + x, y: previousTopLeadingPoint.y + y)
            let topTrailingPoint = CGPoint(x: previousTopTrailingPoint.x + x, y: previousTopTrailingPoint.y + y)
            let bottomLeadingPoint = CGPoint(x: previousBottomLeadingPoint.x + x, y: previousBottomLeadingPoint.y + y)
            let bottomTrailingPoint = CGPoint(x: previousBottomTrailingPoint.x + x, y: previousBottomTrailingPoint.y + y)
            
            self.topLeadingPoint = topLeadingPoint
            self.topTrailingPoint = topTrailingPoint
            self.bottomLeadingPoint = bottomLeadingPoint
            self.bottomTrailingPoint = bottomTrailingPoint
        }
    }
    
    func dragEdge(size: CGSize, edge: EdgePosition) {
        switch edge {
        case .topLeadingPoint:
            let value = (size.width + size.height) / 2
            let topLeadingPoint = CGPoint(x: previousTopLeadingPoint.x + value, y: previousTopLeadingPoint.y + value)
            let topTrailingPoint = CGPoint(x: previousTopTrailingPoint.x, y: previousTopTrailingPoint.y + value)
            let bottomLeadingPoint = CGPoint(x: previousBottomLeadingPoint.x + value, y: previousBottomLeadingPoint.y)
            
            if CheckDraggableUseCase(point1: topLeadingPoint, point2: bottomTrailingPoint, minDiff: minDiff, originRect: originRect).execute() {
                self.topLeadingPoint = topLeadingPoint
                self.topTrailingPoint = topTrailingPoint
                self.bottomLeadingPoint = bottomLeadingPoint
            }
            
        case .topTrailingPoint:
            let value = (size.width - size.height) / 2
            let topTrailingPoint = CGPoint(x: previousTopTrailingPoint.x + value, y: previousTopTrailingPoint.y - value)
            let topLeadingPoint = CGPoint(x: previousTopLeadingPoint.x, y: previousTopLeadingPoint.y - value)
            let bottomTrailingPoint = CGPoint(x: previousBottomTrailingPoint.x + value, y: previousBottomTrailingPoint.y)
            
            if CheckDraggableUseCase(point1: topTrailingPoint, point2: bottomLeadingPoint, minDiff: minDiff, originRect: originRect).execute() {
                self.topTrailingPoint = topTrailingPoint
                self.topLeadingPoint = topLeadingPoint
                self.bottomTrailingPoint = bottomTrailingPoint
            }
        case .bottomLeadingPoint:
            let value = (size.width - size.height) / 2
            let bottomLeadingPoint = CGPoint(x: previousBottomLeadingPoint.x + value, y: previousBottomLeadingPoint.y - value)
            let topLeadingPoint = CGPoint(x: previousTopLeadingPoint.x + value, y: previousTopLeadingPoint.y)
            let bottomTrailingPoint = CGPoint(x: previousBottomTrailingPoint.x, y: previousBottomTrailingPoint.y - value)
            
            if CheckDraggableUseCase(point1: bottomLeadingPoint, point2: topTrailingPoint, minDiff: minDiff, originRect: originRect).execute() {
                self.bottomLeadingPoint = bottomLeadingPoint
                self.topLeadingPoint = topLeadingPoint
                self.bottomTrailingPoint = bottomTrailingPoint
            }
        case .bottomTrailingPoint:
            let value = (size.width + size.height) / 2
            let bottomTrailingPoint = CGPoint(x: previousBottomTrailingPoint.x + value, y: previousBottomTrailingPoint.y + value)
            let bottomLeadingPoint = CGPoint(x: previousBottomLeadingPoint.x, y: previousBottomLeadingPoint.y + value)
            let topTrailingPoint = CGPoint(x: previousTopTrailingPoint.x + value, y: previousTopTrailingPoint.y)
            
            if CheckDraggableUseCase(point1: bottomTrailingPoint, point2: topLeadingPoint, minDiff: minDiff, originRect: originRect).execute() {
                self.bottomTrailingPoint = bottomTrailingPoint
                self.bottomLeadingPoint = bottomLeadingPoint
                self.topTrailingPoint = topTrailingPoint
            }
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
