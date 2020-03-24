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
            self._image = value
            self.updateSize()
            self.updateScale(self.ratio)
            self.updatePos(Vector(0, 0))
        }
    }
    
    var ratio: Float {
        let rHeight = self.gridHeight / self.imageHeight
        let rWidth = self.gridWidth / self.imageWidth
        
        if gridWidth >= gridHeight {
            let newValue = rHeight * imageWidth
            if newValue < gridWidth {
                return rWidth
            }
            return rHeight
        } else {
            let newValue = rWidth * imageHeight
            if newValue < gridHeight {
                return rHeight
            }
            return rWidth
        }
    }
    
    var isImagePortrait: Bool {
        return self.imageWidth <= self.imageHeight
    }
    
    @Published private var _pos = Vector(0, 0)
    var pos: Vector {
        get {
            return self._pos
        }
        set(newPos) {
            updatePos(newPos)
        }
    }
    
    var posBorders: Vector {
        return (
            Vector(imageWidth, imageHeight)
                .scale(self.scale)
                .substract(Vector(
                    gridWidth,
                    gridHeight
                ))
                .divide(2)
                .divide(self.scale)
        )
    }
    
    func updatePos(_ newPos: Vector, _ animate: Bool = false) {
        if Int(self.posBorders.x) < abs(Int(newPos.x)) {
            newPos.x = self.posBorders.x * (newPos.x < 0 ? -1 : 1)
        }
        
        if Int(self.posBorders.y) < abs(Int(newPos.y)) {
            newPos.y = self.posBorders.y * (newPos.y < 0 ? -1 : 1)
        }
        
        if animate {
            withAnimation(.spring()) {
                self._pos = newPos
            }
        } else {
            self._pos = newPos
        }
    }
    
    let maxScale = 3
    @Published private var _scale: Float = 1
    var scale: Float {
        get {
            return _scale
        }
        set(value) {
            self._scale = value
        }
    }
    
    func updateScale(_ scale: Float, _ updatePos: Bool = true) {
        self.scale = scale
        if updatePos {
            self.updatePos(self.pos)
        }
    }
    
    private var _viewImageWidth: Float
    private var _maxWidth = Float(UIScreen.main.bounds.width) - 20
    
    @Published private var _width: Int = 3
    var width: Int {
        get {
            return self._width
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
        if self.image != nil {
            return Float(self.image!.size.width)
        }
        return 0
    }
    
    var gridWidth: Float {
        return self.viewPartWidth * Float(self.width)
    }
    
    @Published  private var _gridHeight: Float = 0
    private var _maxHeight: Float = Float(UIScreen.main.bounds.height / 2)
    
    @Published private var _height: Int = 3
    var height: Int {
        get {
            return self._height
        }
    }
    
    var maxHeight: Float {
        return self._maxHeight
    }
    
    var imageHeight: Float {
        if self.image != nil {
            return Float(self.image!.size.height)
        }
        return 0
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
    
    private func updateSize() {
        let viewImageWidth = self.maxWidth
        let viewPartWidth = viewImageWidth / Float(self.width)
        let gridHeight = viewPartWidth * Float(self.height)
        
        if gridHeight > self.maxHeight {
            let viewPartHeight = self.maxHeight / Float(self.height)
            self.viewImageWidth = viewPartHeight * Float(self.width)
            self._gridHeight = self.maxHeight
        } else {
            self.viewImageWidth = self.maxWidth
            self._gridHeight = gridHeight
        }
        
        if self.scale < self.ratio {
            self.updateScale(self.ratio)
        }
        
        self.updatePos(self.pos)
    }
    
    func setWidthHeight(_ width: Int, _ height: Int) -> Bool {
        var changed = false
        
        
        if width > 0 && self.width != width {
            changed = true
            self._width = width
        }
        
        if height > 0 && self.height != height {
            changed = true
            self._height = height
        }
        
        if changed {
            self.updateSize()
        }
        
        return changed
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
