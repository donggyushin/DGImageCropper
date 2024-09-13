//
//  File.swift
//  DGImageCropper
//
//  Created by 신동규 on 9/13/24.
//

import UIKit

extension UIImage {
    func rotated(by degrees: CGFloat) -> UIImage? {
        // 회전할 각도를 라디안 단위로 변환 (90도 -> π/2)
        let radians = degrees * CGFloat.pi / 180
        
        // 새로운 사이즈 계산 (가로와 세로가 반전됨)
        let newSize = CGSize(width: size.height, height: size.width)
        
        // 그래픽 컨텍스트 시작
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // 회전의 기준점을 이미지의 중심으로 설정
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        
        // 이미지를 90도 회전
        context.rotate(by: radians)
        
        // 회전 후 이미지를 그리기 (가로와 세로 반전)
        draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        
        // 새로운 이미지를 가져오기
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 컨텍스트 종료
        UIGraphicsEndImageContext()
        
        return rotatedImage
    }
}

