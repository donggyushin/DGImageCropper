//
//  File.swift
//  DGImageCropper
//
//  Created by 신동규 on 9/13/24.
//

import Foundation
import CoreGraphics
import UIKit

/// ✅ 문제의 원인
///    •    UIImage는 실제 픽셀 데이터는 그대로 두고, imageOrientation 값을 통해 렌더링 방향을 조정합니다.
///    •    하지만 CGImage를 사용하는 crop, draw, resize 등의 작업에서는 imageOrientation이 무시되어 잘못된 방향으로 처리될 수 있습니다.
///
///    cropImage에서 작업을 시작하기 전에 orientation을 무시하고 정상 방향으로 미리 고정한 이미지로 변환해야 합니다.

extension UIImage {
    func normalizedImage() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage ?? self
    }
}

func cropImage(image: UIImage, imageSizeInScreen: CGSize, rect: CGRect) -> UIImage? {
    
    let image = image.normalizedImage()
    
    let ratio: CGFloat = image.size.width / imageSizeInScreen.width
    
    let rect: CGRect = .init(
        x: rect.minX * ratio,
        y: rect.minY * ratio,
        width: rect.width * ratio,
        height: rect.height * ratio
    )
    
    guard let cgImage = image.cgImage?.cropping(to: rect) else { return nil }
    return UIImage(cgImage: cgImage)
}
