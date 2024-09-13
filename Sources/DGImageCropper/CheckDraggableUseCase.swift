//
//  File.swift
//  DGImageCropper
//
//  Created by 신동규 on 9/13/24.
//

import Foundation

final class CheckDraggableUseCase {
    let point1: CGPoint
    let point2: CGPoint
    let minDiff: CGFloat
    let originRect: CGRect
    
    init(point1: CGPoint, point2: CGPoint, minDiff: CGFloat, originRect: CGRect) {
        self.point1 = point1
        self.point2 = point2
        self.minDiff = minDiff
        self.originRect = .init(x: originRect.minX - 1, y: originRect.minY - 1, width: originRect.width + 2, height: originRect.height + 2)
    }
    
    func execute() -> Bool {
        
        guard originRect.contains(point1)
                && originRect.contains(point2)
        else { return false }
        
        
        let x = abs(point1.x - point2.x)
        let y = abs(point1.y - point2.y)
        return x > minDiff && y > minDiff
    }
}
