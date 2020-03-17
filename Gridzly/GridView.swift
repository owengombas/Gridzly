//
//  GridView.swift
//  Gridzly
//
//  Created by Owen on 17.03.20.
//  Copyright © 2020 ven. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct GridView: Shape {
    func update(width) -> Path {
        var path = Path()
        
        for x in 1..<imageController.width {
            path.move(
                to: CGPoint(
                    x: x * ImageController.instance.viewPartWidth,
                    y: 0
                )
            )
            path.addLine(
                to: CGPoint(
                    x: x * ImageController.instance.viewPartWidth,
                    y: Int(ImageController.instance.viewImageHeight)
                )
            )
        }
        
        for y in 1..<imageController.height {
            path.move(
                to: CGPoint(
                    x: 0,
                    y: y * ImageController.instance.viewPartHeight
                )
            )
            path.addLine(
                to: CGPoint(
                    x: Int(ImageController.instance.viewImageWidth),
                    y: y * ImageController.instance.viewPartHeight
                )
            )
        }

        return path
    }
    
    func path(in rect: CGRect) -> Path {
        return update()
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

