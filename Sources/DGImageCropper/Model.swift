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
    @Published var topLeadingPoint: CGPoint = .zero
    @Published var topTrailingPoint: CGPoint = .zero
    @Published var bottomLeadingPoint: CGPoint = .zero
    @Published var bottomTrailingPoint: CGPoint = .zero
    
    @Published var rect: CGRect = .zero
    
    init() {
        bind()
    }
    
    func configure(size: CGSize) {
        topLeadingPoint = .init(x: 0, y: 0)
        topTrailingPoint = .init(x: size.width, y: 0)
        bottomLeadingPoint = .init(x: 0, y: size.height)
        bottomTrailingPoint = .init(x: size.width, y: size.height)
    }
    
    private func bind() {
        $topLeadingPoint
            .combineLatest($bottomTrailingPoint)
            .map({ point1, point2 in
                var point1 = point1
                var point2 = point2
                point1 = .init(x: point1.x + 2, y: point1.y + 2)
                point2 = .init(x: point2.x - 2, y: point2.y - 2)
                return (point1, point2)
            })
            .map({ GenerateRectUseCase(point1: $0.0, point2: $0.1) })
            .map({ $0.execute() })
            .assign(to: &$rect)
    }
}
