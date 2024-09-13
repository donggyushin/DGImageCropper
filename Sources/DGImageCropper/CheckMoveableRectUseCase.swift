//
//  File.swift
//  DGImageCropper
//
//  Created by 신동규 on 9/13/24.
//

import Foundation

final class CheckMoveableRectUseCase {
    let originRect: CGRect
    let rect: CGRect
    let move: CGSize
    
    init(originRect: CGRect, rect: CGRect, move: CGSize) {
        self.originRect = originRect
        self.rect = rect
        self.move = move
    }
    
    func execute() -> Bool {
        var rect = rect
        rect.origin = .init(x: rect.origin.x + move.width, y: rect.origin.y + move.height)
        
        return originRect.contains(.init(x: rect.minX, y: rect.minY)) &&
        originRect.contains(.init(x: rect.maxX, y: rect.minY)) &&
        originRect.contains(.init(x: rect.minX, y: rect.maxY)) &&
        originRect.contains(.init(x: rect.maxX, y: rect.maxY))
    }
}
