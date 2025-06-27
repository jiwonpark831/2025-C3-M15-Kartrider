//
//  GIFView.swift
//  Kartrider
//
//  Created by J on 6/9/25.
//

import SwiftUI
import UIKit
import ImageIO

// TODO: 안쓰는 파일 및 코드 삭제
struct GIFView: UIViewRepresentable {
    let gifName: String

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.loadGif(name: gifName)
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) { }
}

extension GIFView {
    static func getDelayForImageAtIndex(index: Int, source: CGImageSource) -> Double {
        var delay = 0.1

        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        defer { gifPropertiesPointer.deallocate() }

        if let cfProperties = cfProperties as? [String: Any],
           let gifProperties = cfProperties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
            if let delayTime = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double {
                delay = delayTime
            } else if let delayTime = gifProperties[kCGImagePropertyGIFDelayTime as String] as? Double {
                delay = delayTime
            }
        }

        return delay < 0.01 ? 0.1 : delay
    }
}

extension UIImageView {
    func loadGif(name: String) {
        DispatchQueue.global().async {
            guard let path = Bundle.main.path(forResource: name, ofType: "gif"),
                  let data = NSData(contentsOfFile: path),
                  let source = CGImageSourceCreateWithData(data, nil) else {
                return
            }

            var images = [UIImage]()
            var duration: Double = 0

            let count = CGImageSourceGetCount(source)
            for i in 0..<count {
                guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }

                let delaySeconds = GIFView.getDelayForImageAtIndex(index: i, source: source)
                duration += delaySeconds

                let image = UIImage(cgImage: cgImage)
                images.append(image)
            }

            DispatchQueue.main.async {
                self.animationImages = images
                self.animationDuration = duration
                self.startAnimating()
            }
        }
    }
}
