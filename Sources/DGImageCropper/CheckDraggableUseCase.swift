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
    
    init(point1: CGPoint, point2: CGPoint, minDiff: CGFloat) {
        self.point1 = point1
        self.point2 = point2
        self.minDiff = minDiff
    }
    
    func execute() -> Bool {
        let x = abs(point1.x - point2.x)
        let y = abs(point1.y - point2.y)
        return x > minDiff && y > minDiff
    }
}
