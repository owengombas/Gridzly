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

class ImageController: ObservableObject {
    init() {
        self._viewImageWidth = self._maxWidth
    }
    
    private var _images: [CGImage] = []

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
        return self._viewImageWidth / self.imageWidth
    }
    var isImagePortrait: Bool {
        return self.imageWidth <= self.imageHeight
    }
    
    @Published private var _maskPos = Vector(0, 0)
    var maskPos: Vector {
        get {
            return self._maskPos
        }
        set(newPos) {
            let vSize = Vector(
                Float(self.imageWidth),
                Float(self.imageHeight)
            )
            
            var maxNormalCoordinates =
                vSize.substract(
                    Vector(
                        Float(self.gridWidth),
                        Float(self.gridHeight)
                    )
                )
                
            let vDelta =
                maxNormalCoordinates.substract(
                    maxNormalCoordinates.scale(self.scale)
                )
                .divide(2)
            
            var normalCoordinates = self.convertCoordinatesToNormal(newPos)
            let maxMaskCoordinates = self.convertCoordinatesToMask(maxNormalCoordinates)
            let minMaskCoordinates = self.convertCoordinatesToMask(Vector(0, 0))
            
            print("DELTA: ", vDelta.x, vDelta.y)
            print("POS: ", normalCoordinates.x, normalCoordinates.y)
            print("MAX: ", maxNormalCoordinates.x, maxNormalCoordinates.y)
            print()
//            if normalCoordinates.x > maxNormalCoordinates.x {
//                newPos.x = maxMaskCoordinates.x
//            }
//
//            if normalCoordinates.y > maxNormalCoordinates.y {
//                print(_maskPos)
//                newPos.y = maxMaskCoordinates.y
//            }
//
//            if normalCoordinates.x < 0 {
//                newPos.x = minMaskCoordinates.x
//            }
//
//            if normalCoordinates.y < 0 {
//                newPos.y = minMaskCoordinates.y
//            }
            
            self._maskPos = newPos
        }
    }
    
    @Published var scale: Float = 0.4
    
    @Published private var _width: Int = 3
    private var _viewImageWidth: Float
    private var _maxWidth = Float(UIScreen.main.bounds.width) - 20
    var width: Int {
        get {
            return self._width
        }
        set(value) {
            setGrid(width: value, height: self.height)
        }
    }
    var maxWidth: Float {
        return self._maxWidth
    }
    var viewImageWidth: Float {
        get {
            return self._viewImageWidth
        }
        set(value) {
            if value <= maxWidth {
                self._viewImageWidth = value
            } else {
                self._viewImageWidth = maxWidth
            }
        }
    }
    var viewPartWidth: Float {
        return self.viewImageWidth / Float(self.width)
    }
    var imageWidth: Float {
        return Float(self.image!.size.width)
    }
    var gridWidth: Float {
        return self.viewPartWidth * Float(self.width)
    }
    
    @Published private var _height: Int = 10
    @Published  private var _gridHeight: Float = 0
    private var _maxHeight: Float = Float(UIScreen.main.bounds.height - 300)
    var height: Int {
        get {
            return self._height
        }
        set(value) {
            setGrid(width: self.width, height: value)
            
            let gridHeight = viewPartWidth * Float(self.height)
            self.viewImageWidth *= self._maxHeight / gridHeight
            
            if gridHeight > self._maxHeight {
                self._gridHeight = self.maxHeight
            } else {
                self._gridHeight = gridHeight
            }
        }
    }
    var maxHeight: Float {
        return self._maxHeight
    }
    var imageHeight: Float {
        return Float(self.image!.size.height)
    }
    var viewImageHeight: Float {
        return Float(imageHeight) * ratio
    }
    var viewPartHeight: Float {
        return self.gridHeight / Float(self.height)
    }
    var gridHeight: Float {
        return self._gridHeight
    }
    
    func convertCoordinatesToNormal(_ coordinates: Vector) -> Vector {
        let vB = Vector(
            Float(self.imageWidth),
            Float(self.imageHeight)
        ).divide(2)
        return coordinates.reverse().add(vB)
    }
    
    func convertCoordinatesToMask(_ coordinates: Vector) -> Vector {
        let vB = Vector(
            Float(self.imageWidth),
            Float(self.imageHeight)
        ).divide(2)
        return coordinates.substract(vB).divide(self.scale).reverse()
    }
    
    private func setImage(_ image: UIImage?) {
        self._image = image;
    }
    
    private func setGrid(width: Int, height: Int) {
        self._images = []
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
                    self._images.append(croppedImage!)
                }
            }
        }
    }
    
    func save() {
        for image in self._images {
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
