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
        case width3height4
        case width4height3
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
    private var previousRect: CGRect = .zero
    
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
        self.ratio = ratio
        
        switch ratio {
        case .square:
            let length = min(originRect.width, originRect.height)
            let x = (originRect.width - length) / 2
            let y = (originRect.height - length) / 2
            
            topLeadingPoint = .init(x: x, y: y)
            topTrailingPoint = .init(x: x + length, y: y)
            bottomLeadingPoint = .init(x: x, y: y + length)
            bottomTrailingPoint = .init(x: x + length, y: y + length)
        case .width3height4:
            let h = originRect.height
            let w = h / 4 * 3
            let y = 0.0
            let x = (originRect.width - w) / 2
            
            topLeadingPoint = .init(x: x, y: y)
            topTrailingPoint = .init(x: x + w, y: 0)
            bottomLeadingPoint = .init(x: x, y: h)
            bottomTrailingPoint = .init(x: x + w, y: h)
        case .width4height3:
            let x = 0.0
            let w = originRect.width
            let h = w / 4 * 3
            let y = (originRect.height - h) / 2
            
            topLeadingPoint = .init(x: x, y: y)
            topTrailingPoint = .init(x: x + w, y: y)
            bottomLeadingPoint = .init(x: x, y: y + h)
            bottomTrailingPoint = .init(x: x + w, y: h + y)
        }
        
        updatePreviousRef()
    }
    
    func configure(size: CGSize) {
        originRect = GenerateRectUseCase(
            point1: .init(x: 0, y: 0),
            point2: .init(x: size.width, y: size.height)
        ).execute()
        changeRatio(ratio: ratio)
    }
    
    func move(size: CGSize) {
        let x = size.width
        let y = size.height
        
        if CheckMoveableRectUseCase(originRect: originRect, rect: GenerateRectUseCase(point1: previousTopLeadingPoint, point2: previousBottomTrailingPoint).execute(), move: size).execute() {
            let topLeadingPoint = CGPoint(x: previousTopLeadingPoint.x + x, y: previousTopLeadingPoint.y + y)
            let topTrailingPoint = CGPoint(x: previousTopTrailingPoint.x + x, y: previousTopTrailingPoint.y + y)
            let bottomLeadingPoint = CGPoint(x: previousBottomLeadingPoint.x + x, y: previousBottomLeadingPoint.y + y)
            let bottomTrailingPoint = CGPoint(x: previousBottomTrailingPoint.x + x, y: previousBottomTrailingPoint.y + y)
            
            self.topLeadingPoint = topLeadingPoint
            self.topTrailingPoint = topTrailingPoint
            self.bottomLeadingPoint = bottomLeadingPoint
            self.bottomTrailingPoint = bottomTrailingPoint
        } else {
            // Edge case
            if size.width <= 0 && size.height <= 0 {
                let topLeadingPoint = CGPoint(x: max(previousTopLeadingPoint.x + x, 0), y: max(previousTopLeadingPoint.y + y, 0))
                let topTrailingPoint = CGPoint(x: topLeadingPoint.x + previousRect.width, y: topLeadingPoint.y)
                let bottomLeadingPoint = CGPoint(x: topLeadingPoint.x, y: topLeadingPoint.y + previousRect.height)
                let bottomTrailingPoint = CGPoint(x: topLeadingPoint.x + previousRect.width, y: topLeadingPoint.y + previousRect.height)
                
                self.topLeadingPoint = topLeadingPoint
                self.topTrailingPoint = topTrailingPoint
                self.bottomLeadingPoint = bottomLeadingPoint
                self.bottomTrailingPoint = bottomTrailingPoint
            } else if size.width >= 0 && size.height <= 0 {
                let topTrailingPoint = CGPoint(x: min(previousTopTrailingPoint.x + x, originRect.maxX), y: max(0, previousTopTrailingPoint.y + y))
                let topLeadingPoint = CGPoint(x: topTrailingPoint.x - previousRect.width, y: topTrailingPoint.y)
                let bottomLeadingPoint = CGPoint(x: topTrailingPoint.x - previousRect.width, y: topTrailingPoint.y + previousRect.height)
                let bottomTrailingPoint = CGPoint(x: topTrailingPoint.x, y: topTrailingPoint.y + previousRect.height)
                
                self.topTrailingPoint = topTrailingPoint
                self.topLeadingPoint = topLeadingPoint
                self.bottomLeadingPoint = bottomLeadingPoint
                self.bottomTrailingPoint = bottomTrailingPoint
            } else if size.width <= 0 && size.height >= 0 {
                let bottomLeadingPoint = CGPoint(x: max(previousBottomLeadingPoint.x + x, 0), y: min(previousBottomLeadingPoint.y + y, originRect.height))
                let topLeadingPoint = CGPoint(x: bottomLeadingPoint.x, y: bottomLeadingPoint.y - previousRect.height)
                let bottomTrailingPoint = CGPoint(x: bottomLeadingPoint.x + previousRect.width, y: bottomLeadingPoint.y)
                let topTrailingPoint = CGPoint(x: bottomLeadingPoint.x + previousRect.width, y: bottomLeadingPoint.y - previousRect.height)
                
                self.bottomLeadingPoint = bottomLeadingPoint
                self.topLeadingPoint = topLeadingPoint
                self.bottomTrailingPoint = bottomTrailingPoint
                self.topTrailingPoint = topTrailingPoint
            } else if size.width >= 0 && size.height >= 0 {
                let bottomTrailingPoint = CGPoint(x: min(previousBottomTrailingPoint.x + x, originRect.maxX), y: min(previousBottomTrailingPoint.y + y, originRect.maxY))
                self.bottomTrailingPoint = bottomTrailingPoint
            }
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
        previousRect = rect
    }
    
    private func bind() {
        $topLeadingPoint
            .combineLatest($bottomTrailingPoint)
            .map({ GenerateRectUseCase(point1: $0.0, point2: $0.1) })
            .map({ $0.execute() })
            .assign(to: &$rect)
    }
}
