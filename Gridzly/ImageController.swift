//
//  ImageController.swift
//  Gridzly
//
//  Created by Owen on 17.03.20.
//  Copyright © 2020 ven. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class ImageController: NSObject {
    private static var _instance: ImageController?
    static var instance: ImageController {
        get {
            if self._instance == nil {
                self._instance = ImageController()
            }
            return self._instance!
        }
        set(value) {
            self._instance = value
        }
    }

    private var images: [CGImage] = []

    private var _image: UIImage?
    var image: UIImage? {
        get {
            return self._image
        }
        set(value) {
            setImage(value)
        }
    }
    var ratio: Float {
        return Float(UIScreen.main.bounds.height / 2) / Float(self.imageHeight)
    }
    
    private var _viewGeometry: GeometryProxy?
    var viewGeometry: GeometryProxy? {
        get {
            return self._viewGeometry
        }
        set(value) {
            self._viewGeometry = value
        }
    }

    private var _width: Int = 2
    var width: Int {
        get {
            return self._width
        }
        set(value) {
            setGrid(width: value, height: self.height)
        }
    }
    var imageWidth: Int {
        return Int(self.image!.size.width)
    }
    var viewImageWidth: Int {
        return Int(Float(self.imageWidth) * self.ratio)
    }
    var absolutePartWidth: Int {
        return self.imageWidth / self.width
    }
    var viewPartWidth: Int {
        return self.viewImageWidth / self.width
    }
    
    private var _height: Int = 2
    var height: Int {
        get {
            return self._height
        }
        set(value) {
            setGrid(width: self.width, height: value)
        }
    }
    var imageHeight: Int {
        return Int(self.image!.size.height)
    }
    var viewImageHeight: Int {
        return viewImageWidth
        // return Int(Float(self.imageHeight) * self.ratio)
    }
    var absolutePartHeightHeight: Int {
        return self.imageHeight / self.height
    }
    var viewPartHeight: Int {
        return self.viewImageHeight / self.height
    }
    
    private func setImage(_ image: UIImage?) {
        self._image = image;
    }
    
    private func setGrid(width: Int, height: Int) {
        self.images = []
        if image != nil {
            self._width = width
            self._height = height

            let imageWidth = Int(self.image!.size.width)
            let imageHeight = Int(self.image!.size.height)

            let partWidth = imageWidth / self.width
            let partHeight = imageHeight / self.height
            
            for x in 0..<width {
                for y in 0..<height {
                    let rect = CGRect(
                        x: x * partWidth,
                        y: y * partHeight,
                        width: partWidth,
                        height: partHeight
                    )
                    let croppedImage = self.image!.cgImage?.cropping(to: rect)!
                    self.images.append(croppedImage!)
                }
            }
        }
    }
    
    func save() {
        for image in self.images {
            let savableImage = UIImage(cgImage: image, scale: 1, orientation: .up)
            UIImageWriteToSavedPhotosAlbum(savableImage, self, #selector(saveError), nil)
        }
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        // save complete
    }

    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
