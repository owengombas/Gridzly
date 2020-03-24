//
//  Vector.swift
//  Gridzly
//
//  Created by owen on 20.03.20.
//  Copyright © 2020 ven. All rights reserved.
//

import Foundation
import UIKit

class Vector {
    var x: Float!
    var y: Float!
    var startPoint: CGPoint?
    var endPoint: CGPoint?
    
    var norm: Float {
        return sqrt(pow(self.x, 2) + pow(self.y, 2))
    }
    
    init(_ startPoint: CGPoint, _ endPoint: CGPoint) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        computePos()
    }
    
    init(_ x: Float, _ y: Float) {
        self.x = x
        self.y = y
    }
    
    convenience init(_ endPoint: CGPoint) {
        self.init(CGPoint(x: 0, y: 0), endPoint)
    }
    
    func angle(with: Vector) -> Float {
        return acos(abs(scalarProduct(with: with) / (self.norm * with.norm)))
    }
    
    func angleDeg(with: Vector) -> Float {
        return 180 / Float.pi * angle(with: with)
    }
    
    func scalarProduct(with: Vector) -> Float {
        return self.x * with.x + self.y * with.y
    }
    
    func normalize() -> Vector {
        let out = Vector(x, y)
        out.x /= norm
        out.y /= norm
        return out
    }
    
    func rotatePerp() -> Vector {
        let out = Vector(x, y)
        out.x = -y
        out.y = x
        return out
    }
    
    func add(_ vector: Vector) -> Vector {
        let out = Vector(x, y)
        out.x += vector.x
        out.y += vector.y
        return out
    }
    
    func add(_ number: Float) -> Vector {
        let out = Vector(x, y)
        out.x += number
        out.y += number
        return out
    }
    
    func substract(_ vector: Vector) -> Vector {
        let out = Vector(x, y)
        out.x -= vector.x
        out.y -= vector.y
        return out
    }
    
    func substract(_ number: Float) -> Vector {
        return add(-number)
    }
    
    func scale(_ by: Float) -> Vector {
        let out = Vector(x, y)
        out.x *= by
        out.y *= by
        return out
    }
    
    func reverse() -> Vector {
        return scale(-1)
    }
    
    func divide(_ by: Float) -> Vector {
        return scale(1 / by)
    }
    
    func copy() -> Vector {
        return Vector(x, y)
    }
    
    func toPoint() -> CGPoint {
        return CGPoint(x: CGFloat(self.x), y: CGFloat(self.y))
    }
    
    private func computePos() {
        if self.startPoint != nil && self.endPoint != nil {
            x = Float(self.endPoint!.x - self.startPoint!.x)
            y = Float(self.endPoint!.y - self.startPoint!.y)
        }
    }
}
