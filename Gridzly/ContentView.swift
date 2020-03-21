//
//  ContentView.swift
//  Gridzly
//
//  Created by Owen on 08.02.20.
//  Copyright © 2020 ven. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var lastScale: Float = 1
    @State var vPrev: Vector?
    @State var firstValue: DragGesture.Value?
    @State var pathTrim: CGFloat = 1
    @ObservedObject var imgCtrl: ImageController = ImageController()
    
    var scaleMovingFactor: Float {
        return 1 - self.imgCtrl.scale
    }

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                ZStack {
                    self.viewImage()
                        .antialiased(true)
                        .position(self.imgCtrl.maskPos.toPoint())
                        .scaleEffect(CGFloat(self.imgCtrl.scale))
                        .frame(
                            width: CGFloat(self.imgCtrl.gridWidth),
                            height: CGFloat(self.imgCtrl.gridHeight),
                            alignment: .center
                        )
                        // .animation(.spring()) TODO MANUAL
                        .mask(
                            Rectangle()
                                .frame(
                                    width: CGFloat(self.imgCtrl.gridWidth),
                                    height: CGFloat(self.imgCtrl.gridHeight),
                                    alignment: .center
                                )
                                .animation(.spring())
                        )

                    getPath()
                        .trim(from: self.pathTrim, to: 1)
                        .stroke(Color.white, lineWidth: 2)
                        .opacity(0.3)
                        .frame(
                            width: CGFloat(self.imgCtrl.viewImageWidth),
                            height: CGFloat(self.imgCtrl.gridHeight)
                        )
                        .onAppear(perform: self.animatePath)
                }
                .shadow(color: Color(.sRGB, white: 0, opacity: 0.5), radius: 10, x: 0, y: 5)
                .gesture(DragGesture().onChanged(self.drag).onEnded(self.dragEnded))
                .gesture(MagnificationGesture().onChanged(self.pinch).onEnded(self.pinchEnded))

                VStack(spacing: 0) {
                    Text("height")
                    .font(.custom("Metropolis-bold", size: 23))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Stepper(
                        onIncrement: self.incrementHeight,
                        onDecrement: self.decrementHeight
                    ) {
                        Text(String(self.imgCtrl.height))
                        .font(.custom("Metropolis-medium", size: 20))
                    }.padding(.top, 3)
                }.padding(.horizontal, 10).padding(.top, 15).animation(.spring())
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
    
    init() {
        self.imgCtrl.image = UIImage(named: "limage")
        self.imgCtrl.height = 3
    }
    
    func viewImage() -> Image {
        return Image("limage")
    }
    
    func pinch(_ value: MagnificationGesture.Value) {
        let delta = Float(value) / self.lastScale
        self.lastScale = Float(value)
        let newValue = self.imgCtrl.scale * delta
        if newValue <= 1 && newValue >= self.imgCtrl.ratio {
            self.imgCtrl.scale = newValue
        }
    }
    
    func pinchEnded(_ value: MagnificationGesture.Value) {
        self.lastScale = 1
    }
    
    func drag(_ value: DragGesture.Value) -> Void {
        let vCurr = Vector(value.location)
        
        if vPrev != nil {
            let vPrevCurr = vCurr.substract(vPrev!)
            let vFinal = (
                vPrevCurr.scale(self.scaleMovingFactor * 5 + 1)
            )

            let newPos = self.imgCtrl.maskPos.add(vFinal)
            self.imgCtrl.maskPos = newPos
        } else {
            self.firstValue = value
        }
        
        vPrev = vCurr
    }
    
    func dragEnded(_ value: DragGesture.Value) -> Void {
        let vTranslation = Vector(
            Float(value.predictedEndTranslation.width),
            Float(value.predictedEndTranslation.height)
        )
        
        withAnimation(.easeOut(duration: 0.5)) {
            if vTranslation.norm > 250 {
                self.imgCtrl.maskPos = self.imgCtrl.maskPos.add(
                    vTranslation.scale(self.scaleMovingFactor * 3 + 1)
                )
            }
        }
        
        self.vPrev = nil
    }
    
    func getPosValue(_ delta: CGFloat) -> CGFloat {
        let increment = delta == 0 ? 0 : delta > 0 ? 1 : -1
        let velocity = delta == 0 ? 0 : (abs(1 - abs((1 / delta))) * 7 + 1)
        return (CGFloat(increment) * CGFloat(velocity)).rounded(.up)
    }
    
    func save() {
        self.imgCtrl.save()
    }
    
    func setSize(value: inout Int, increment: Int) {
        value = value + increment
        animatePath()
    }
    
    func animatePath() {
        self.pathTrim = 1
        withAnimation(.easeOut(duration: 0.5)) {
            self.pathTrim = 0
        }
        
    }
    
    func incrementHeight() {
        setSize(value: &self.imgCtrl.height, increment: 1)
    }
    
    func decrementHeight() {
        setSize(value: &self.imgCtrl.height, increment: -1)
    }
    
    func getPath() -> Path {
        var path = Path()
        
        for y in 1..<self.imgCtrl.height {
            path.move(
                to: CGPoint(
                    x: 0,
                    y: y * Int(self.imgCtrl.viewPartHeight)
                )
            )
            path.addLine(
                to: CGPoint(
                    x: Int(self.imgCtrl.viewImageWidth),
                    y: y * Int(self.imgCtrl.viewPartHeight)
                )
            )
        }
        
        for x in 1..<self.imgCtrl.width {
            path.move(
                to: CGPoint(
                    x: x * Int(self.imgCtrl.viewPartWidth),
                    y: 0
                )
            )
            path.addLine(
                to: CGPoint(
                    x: x * Int(self.imgCtrl.viewPartWidth),
                    y: Int(self.imgCtrl.gridHeight)
                )
            )
        }
        
        path = path.scale(-1).path(in: path.boundingRect)
        
        return path
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
