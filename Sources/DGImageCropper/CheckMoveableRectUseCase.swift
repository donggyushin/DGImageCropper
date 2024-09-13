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
        rect = .init(
            x: rect.minX + move.width,
            y: rect.minY + move.height,
            width: rect.width,
            height: rect.height
        )
        
        return originRect.contains(rect)
    }
}
