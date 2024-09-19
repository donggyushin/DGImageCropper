//
//  File.swift
//  DGImageCropper
//
//  Created by 신동규 on 9/13/24.
//

import Foundation

final class GenerateRectUseCase {
    let point1: CGPoint
    let point2: CGPoint
    
    init(point1: CGPoint, point2: CGPoint) {
        self.point1 = point1
        self.point2 = point2
    }
    
    func execute() -> CGRect {
        CGRect(origin: origin(), size: size())
    }
    
    private func origin() -> CGPoint {
        let x = min(point1.x, point2.x)
        let y = min(point1.y, point2.y)
        return .init(x: x, y: y)
    }
    
    private func size() -> CGSize {
        let width = abs(point1.x - point2.x)
        let height = abs(point1.y - point2.y)
        return .init(width: width, height: height)
    }
}
