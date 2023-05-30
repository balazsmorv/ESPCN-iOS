//
//  UIImage+.swift
//  ESPCN
//
//  Created by Balázs Morvay on 2023. 05. 29..
//

import Foundation
import UIKit

extension UIImage {
    
    func pixelData() -> [UInt8]? {
        let size = self.size
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 4 * Int(size.width),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        guard let cgImage = self.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return pixelData
    }
}


/// An extension to provide conversion to and from Y′CbCr colors.
extension UIColor {
    
    /// The Rec.601 (standard-definition) coefficients used to calculate luma.
    private static let encoding: (r: CGFloat, g: CGFloat, b: CGFloat) = (0.299, 0.587, 0.114)

    /// The Y′CbCr components of a color - luma (Y′) and chroma (Cb,Cr).
    struct YCbCr: Hashable {

        /// The luma component of the color, in the full range [0, 255] (black to white).
        var Y: CGFloat
        /// The blue-difference chroma component of the color, in the full range [0, 255].
        var Cb: CGFloat
        /// The red-difference chroma component of the color, in the full range [0, 255].
        var Cr: CGFloat

    }

    /// The Y′CbCr components of the color using Rec.601 (standard-definition) encoding.
    var yCbCr: YCbCr {
        var (r, g, b) = (CGFloat(), CGFloat(), CGFloat())
        getRed(&r, green: &g, blue: &b, alpha: nil)

        let k = UIColor.encoding
        var Y = (k.r * r) + (k.g * g) + (k.b * b)
        var Cb = 0.5 * ((b - Y) / (1.0 - k.b))
        var Cr = 0.5 * ((r - Y) / (1.0 - k.r))
        
        Y  = (Y  * 255.0)
        Cb = (Cb * 255.0) + 127.5
        Cr = (Cr * 255.0) + 127.5

        return YCbCr(Y: Y, Cb: Cb, Cr: Cr)
    }

    /// Initializes a color from Y′CbCr components.
    /// - parameter yCbCr: The components used to initialize the color.
    /// - parameter alpha: The alpha value of the color.
    convenience init(_ yCbCr: YCbCr, alpha: CGFloat = 1.0) {
        let Y  = (yCbCr.Y  / 255.0)
        let Cb = (yCbCr.Cb / 255.0) - 0.5
        let Cr = (yCbCr.Cr / 255.0) - 0.5

        let k = UIColor.encoding
        let kr = (Cr * ((1.0 - k.r) / 0.5))
        let kgb = (Cb * ((k.b * (1.0 - k.b)) / (0.5 * k.g)))
        let kgr = (Cr * ((k.r * (1.0 - k.r)) / (0.5 * k.g)))
        let kb = (Cb * ((1.0 - k.b) / 0.5))

        let r = Y + kr
        let g = Y - kgb - kgr
        let b = Y + kb

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

}
