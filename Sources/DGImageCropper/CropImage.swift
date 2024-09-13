//
//  File.swift
//  DGImageCropper
//
//  Created by 신동규 on 9/13/24.
//

import Foundation
import CoreGraphics
import UIKit

func crop(image: UIImage, imageSizeInScreen: CGSize, rect: CGRect) -> UIImage? {
    let ratio = image.size.width / imageSizeInScreen.width
    
    let rect: CGRect = .init(
        x: rect.minX * ratio,
        y: rect.minY * ratio,
        width: rect.width * ratio,
        height: rect.height * ratio
    )
    
    guard let cgImage = image.cgImage?.cropping(to: rect) else { return nil }
    return UIImage(cgImage: cgImage)
}
