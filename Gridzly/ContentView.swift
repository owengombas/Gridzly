//
//  ContentView.swift
//  Gridzly
//
//  Created by Owen on 08.02.20.
//  Copyright © 2020 ven. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var width: Int = 2
    @State var height: Int = 2
    @State var maskY: Int = 0
    
    let min = 1
    let max = 6

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                ZStack {
                    Image("Image")
                        .antialiased(true)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                        .frame(
                            width: CGFloat(ImageController.instance.viewImageWidth),
                            height: CGFloat(UIScreen.main.bounds.height / 2),
                            alignment: .top
                        )
                        .opacity(0.3)
                        .shadow(color: Color(.sRGB, white: 0, opacity: 0.2), radius: 10, x: 0, y: 5)
                    Image("Image")
                        .antialiased(true)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: CGFloat(ImageController.instance.viewImageWidth),
                            height: CGFloat(UIScreen.main.bounds.height / 2),
                            alignment: .top
                        )
                        .mask(
                            Rectangle()
                                .size(
                                    width: CGFloat(ImageController.instance.viewImageWidth),
                                    height: CGFloat(ImageController.instance.viewImageWidth)
                                )
                                .transform(CGAffineTransform(translationX: 0, y: CGFloat(self.maskY)))
                        )
                        .cornerRadius(10)

                    getPath()
                        .transform(CGAffineTransform(translationX: 0, y: CGFloat(self.maskY)))
                        .stroke(Color.white, lineWidth: 2)
                        .opacity(0.3)
                        .frame(
                            width: CGFloat(ImageController.instance.viewImageWidth),
                            height: CGFloat(UIScreen.main.bounds.height / 2),
                            alignment: .top
                        )
                }
                .gesture(DragGesture().onChanged { (value: DragGesture.Value) in
                    self.maskY = Int(value.location.y)
                })
                .onTapGesture {
                    // ImagePicker
                }

                VStack(spacing: 0) {
                    Text("vertical")
                    .font(.custom("Metropolis-bold", size: 23))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Stepper(
                        onIncrement: self.incrementHeight,
                        onDecrement: self.decrementHeight
                    ) {
                        Text("\(height)")
                        .font(.custom("Metropolis-medium", size: 20))
                    }.padding(.top, 3).padding(.bottom, 15)
                    
                    Text("horizontal")
                    .font(.custom("Metropolis-bold", size: 23))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Stepper(
                        onIncrement: self.incrementWidth,
                        onDecrement: self.decrementWidth
                    ) {
                        Text("\(width)")
                        .font(.custom("Metropolis-medium", size: 20))
                    }.padding(.top, 3)
                }.padding(.horizontal, 10).padding(.top, 15)
            }
            
            Spacer()
            
            Button(action: self.save) {
                Text("save")
                    .padding(.horizontal, 17)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.1, green: 0, blue: 1))
                    .font(.custom("Metropolis-bold", size: 23))
                    .foregroundColor(.white)
                    .cornerRadius(10, antialiased: true)
                    .shadow(color: Color(red: 0.1, green: 0, blue: 1, opacity: 0.25), radius: 10, x: 0, y: 5)
            }
        }
        .padding(20)
    }
    
    func updateGeometry(_ geometry: GeometryProxy) -> EmptyView {
        ImageController.instance.viewGeometry = geometry
        return EmptyView()
    }
    
    func save() {
        ImageController.instance.save()
    }
    
    
    func setSize(value: inout Int, increment: Int) {
        if (value <= self.max && value >= self.min) {
            value += increment
        }
    }

    func incrementWidth() {
        setSize(value: &self.width, increment: 1)
    }
    
    func decrementWidth() {
        setSize(value: &self.width, increment: -1)
    }
    
    func incrementHeight() {
        setSize(value: &self.height, increment: 1)
    }
    
    func decrementHeight() {
        setSize(value: &self.height, increment: -1)
    }
    
    func updateGrid() {
        ImageController.instance.width = self.width
        ImageController.instance.height = self.height
    }
    
    func getPath() -> Path {
        self.updateGrid()
        var path = Path()
        
        for x in 1..<self.width {
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
        
        for y in 1..<self.height {
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
