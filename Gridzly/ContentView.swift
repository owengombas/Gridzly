//
//  ContentView.swift
//  Gridzly
//
//  Created by Owen on 08.02.20.
//  Copyright © 2020 ven. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let maxScale: Float = 3
    let generator = UINotificationFeedbackGenerator()
    let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)
    let primaryColor = Color(red: 0.305, green: 0.35, blue: 1)
    let primaryColor2 = Color(red: 0.305, green: 0.501, blue: 1)
    let gridImages: [[Int]] = [
        [3, 1],
        [3, 2],
        [3, 3],
        [3, 4]
    ]
    var scaleMovingFactor: Float {
        return 1 / self.imgCtrl.scale
    }
    
    
    @State var lastScale: Float = 1
    @State var prevValue: DragGesture.Value?
    @State var vPrev: Vector?
    @State var firstValue: DragGesture.Value?
    @State var pathTrim: CGFloat = 1
    @State var customSize = false
    @State var showImagePicker = false
    @State var image: Image?
    @State var scaleAnimation: Animation? = nil
    @State var saved = false
    @State var showImportScreen = true
    @State var showImportScreenContent = true
    @State var isPro = false
    @ObservedObject var imgCtrl: ImageController = ImageController()
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.localStatusBarStyle) var statusBarStyle
    
    init() {
        self.setSize(3, 3)
        self.statusBarStyle.currentStyle = .lightContent
    }

    var body: some View {
        ZStack {
            VStack {
                if self.image != nil {
                    Button(action: self.importPicture) {
                        Text("Change the picture")
                            .font(.custom("Metropolis-medium", size: 18))
                            .foregroundColor(primaryColor2)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                    }
                    .padding(.top, 10)
                    
                    VStack(spacing: 0) {
                        ZStack {
                            self.image!
                                .offset(x: CGFloat(self.imgCtrl.pos.x), y: CGFloat(self.imgCtrl.pos.y))
                                .animation(.timingCurve(0, 0, 0.3, 1, duration: 1))
                                .scaleEffect(CGFloat(self.imgCtrl.scale))
                                .animation(self.scaleAnimation)
                                .animation(.default)
                                .frame(
                                    width: CGFloat(self.imgCtrl.gridWidth),
                                    height: CGFloat(self.imgCtrl.gridHeight),
                                    alignment: .center
                                )

                                getPath()
                                    .trim(from: self.pathTrim, to: 1)
                                    .stroke(Color.white, lineWidth: 2)
                                    .opacity(0.3)
                                    .frame(
                                        width: CGFloat(self.imgCtrl.gridWidth),
                                        height: CGFloat(self.imgCtrl.gridHeight),
                                        alignment: .center
                                    )
                                    .onAppear(perform: self.animatePath)
                                    .shadow(color: Color(.sRGB, white: 0, opacity: 0.9), radius: 5, x: 0, y: 5)
                        }
                        .cornerRadius(5, antialiased: true)
                        .shadow(color: Color(.sRGB, white: 0, opacity: 0.2), radius: 10, x: 0, y: 5)
                        .gesture(DragGesture().onChanged(self.drag).onEnded(self.dragEnded))
                        .gesture(MagnificationGesture().onChanged(self.pinch).onEnded(self.pinchEnded))
                    }
                    .frame(
                        width: CGFloat(self.imgCtrl.maxWidth),
                        height: CGFloat(self.imgCtrl.maxHeight),
                        alignment: .center
                    )
                    .animation(.spring())
                    .zIndex(-999999)
                    
                    Spacer()

                    VStack {
                        ZStack {
                            if self.customSize {
                                VStack {
                                    Group {
                                        Group {
                                            Stepper(
                                                onIncrement: self.incrementHeight,
                                                onDecrement: self.decrementHeight
                                            ) {
                                                Text("height")
                                                    .font(.custom("Metropolis-medium", size: 23))
                                                    .fontWeight(.bold)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                Text(String(self.imgCtrl.height))
                                                    .font(.custom("Metropolis-medium", size: 23))
                                                    .padding(.horizontal, 8)
                                            }
                                        }
                                        
                                        Group {
                                            Stepper(
                                                onIncrement: self.incrementWidth,
                                                onDecrement: self.decrementWidth
                                            ) {
                                                Text("width")
                                                    .font(.custom("Metropolis-medium", size: 23))
                                                    .fontWeight(.bold)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                Text(String(self.imgCtrl.width))
                                                    .font(.custom("Metropolis-medium", size: 23))
                                                    .padding(.horizontal, 8)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    Button(action: {
                                        withAnimation {
                                            self.customSize.toggle()
                                        }
                                    }) {
                                        Text("Use a predifined size")
                                            .foregroundColor(primaryColor2)
                                            .font(.custom("Metropolis-medium", size: 15))
                                    }
                                    .padding(.top, 10)
                                }
                                .frame(minWidth: 0, maxWidth: 500, minHeight: 0, maxHeight: 100, alignment: .center)
                            } else {
                                VStack {
                                    HStack {
                                        ForEach(self.gridImages, id: \.self[1]) { image in
                                            Button(action: {
                                                self.setSize(image[0], image[1])
                                            }) {
                                                Image(String(image[1]) + (self.colorScheme == .light ? "" : "d"))
                                                    .renderingMode(.original)
                                                    .resizable()
                                                    .aspectRatio(CGSize(width: image[0], height: image[1]), contentMode: .fit)
                                                    .padding(.horizontal, 18)
                                            }
                                            .opacity(self.isImageRatio(image[0], image[1]) ? 0.5 : 0.3)
                                            .frame(minWidth: 0, maxWidth: 100, minHeight: 0, maxHeight: .infinity, alignment: .center)
                                        }
                                    }
                                    
                                    Button(action: {
                                        withAnimation {
                                            self.customSize.toggle()
                                        }
                                    }) {
                                        Text("Use a custom size")
                                            .font(.custom("Metropolis-medium", size: 15))
                                            .foregroundColor(primaryColor2)
                                    }
                                    .padding(.top, 10)
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 100, alignment: .center)
                            }
                        }
                        .transition(.opacity)
                        
                        Button(action: self.save) {
                            Text("Save")
                                .font(.custom("Metropolis-bold", size: 20))
                                .padding(.horizontal, 52)
                                .padding(.vertical, 11)
                                .background(primaryColor)
                                .foregroundColor(.white)
                                .cornerRadius(7, antialiased: true)
                        }
                        .padding(.top, 45)
                        .padding(.bottom, 15)
                    }
                    .padding(.top, 20)
                }
            }
            .sheet(isPresented: self.$showImagePicker) {
                ImagePicker(onSelect: self.onSelect, onDismiss: self.onDismiss)
            }
            
            VStack {
                VStack {
                    if self.showImportScreenContent {
                        Spacer()
                        
                        Group {
                            if self.saved {
                                Text("Saved !")
                                    .font(.custom("Metropolis-medium", size: 38))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 100, alignment: .center)
                            } else {
                                Text("Gridzly")
                                    .font(.custom("Metropolis-bold", size: 38))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 100, alignment: .center)
                            }
                        }
                        .transition(.slide)
                        
                        Spacer()
                        
                        Button(action: {
                            self.toggleImportScreen()
                            self.importPicture()
                        }) {
                            Text("Import a picture")
                                .fontWeight(.bold)
                                .font(.custom("Metropolis-bold", size: 20))
                                .padding(.horizontal, 52)
                                .padding(.vertical, 11)
                                .background(Color.white)
                                .foregroundColor(primaryColor)
                                .cornerRadius(7, antialiased: true)
                        }
                        .padding(.bottom, 45)
                    }
                }
                .frame(
                    minWidth: 0,
                    maxWidth: self.showImportScreen ? .infinity : 0,
                    minHeight: 0,
                    maxHeight: self.showImportScreen ? .infinity : 0,
                    alignment: .center
                )
                .background(primaryColor)
                .padding(.bottom, self.showImportScreen ? 0 : 35.5)
                .animation(.timingCurve(0, 0, 0.1, 1, duration: 0.2))
            }
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .bottom
            )
            .zIndex(9)
            .onTapGesture {
                self.importPicture()
            }
        }
        .edgesIgnoringSafeArea(self.showImportScreen ? .all : .horizontal)
    }
    
    func showPro() {
    }
    
    func isImageRatio(_ width: Int, _ height: Int) -> Bool {
        return (
            self.imgCtrl.height == height &&
            self.imgCtrl.width == width
        )
    }
    
    func onSelect(uiImage: UIImage?) {
        self.imgCtrl.image = uiImage
        if uiImage != nil {
            self.image = Image(uiImage: uiImage!)
            self.animatePath()
            self.hideImportScreen()
            self.rigidGenerator.impactOccurred()
        } else {
            self.displayImportScreen()
            self.image = nil
        }
    }
    
    func onDismiss() {
        if self.image == nil {
            self.displayImportScreen()
        } else {
            self.hideImportScreen()
        }
    }
    
    func pinch(_ value: MagnificationGesture.Value) {
        self.scaleAnimation = nil
        
        let delta = Float(value) / self.lastScale
        self.lastScale = Float(value)
        let newValue = self.imgCtrl.scale * delta
        
        if newValue > self.maxScale {
            self.imgCtrl.updateScale(newValue, false)
        } else if newValue < self.imgCtrl.ratio {
            self.imgCtrl.updateScale(newValue, false)
        } else {
            self.imgCtrl.updateScale(newValue)
        }
    }
    
    func pinchEnded(_ value: MagnificationGesture.Value) {
        self.scaleAnimation = .spring()
        
        if self.imgCtrl.scale > self.maxScale {
            self.imgCtrl.updateScale(self.maxScale)
        }
        
        if self.imgCtrl.scale < self.imgCtrl.ratio {
            self.imgCtrl.updateScale(self.imgCtrl.ratio)
        }
        
        self.lastScale = 1
    }
    
    func drag(_ value: DragGesture.Value) -> Void {
        let vCurr = Vector(value.location)
        
        if vPrev == nil {
            vPrev = vCurr
        }
        
        let vFinal = vCurr.substract(vPrev!).scale(self.scaleMovingFactor)
        let newPos = self.imgCtrl.pos.add(vFinal)
        
        self.imgCtrl.pos = newPos
        self.prevValue = value
        self.vPrev = vCurr
    }
    
    func dragEnded(_ value: DragGesture.Value) -> Void {
        if self.prevValue != nil {
            let vTranslation = Vector(
                Float(value.predictedEndTranslation.width),
                Float(value.predictedEndTranslation.height)
            )

            let time = value.time.timeIntervalSince(self.prevValue!.time)
            let speed = abs(CGFloat(value.translation.height - self.prevValue!.translation.height) / CGFloat(time))

            if speed > 235 {
                let newPos = self.imgCtrl.pos.add(
                    vTranslation.scale(self.scaleMovingFactor)
                )
                
                self.imgCtrl.pos = newPos
            }
        }
        
        self.prevValue = nil
        self.vPrev = nil
    }
    
    func save() {
        self.imgCtrl.save()
        self.displayImportScreen(true)
        self.image = nil
        self.generator.notificationOccurred(.success)
    }
    
    func toggleImportScreen(_ saved: Bool = false) {
        if self.showImportScreen {
            self.hideImportScreen()
        } else {
            self.displayImportScreen(saved)
        }
    }
    
    func hideImportScreen() {
        self.statusBarStyle.currentStyle = .default
        self.saved = false
        self.showImportScreenContent = false
        self.showImportScreen = false
    }
    
    func displayImportScreen(_ saved: Bool = false) {
        self.statusBarStyle.currentStyle = .lightContent
        
        self.showImportScreen = true
        self.saved = saved
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.showImportScreenContent = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                self.saved = false
            }
        }
    }
    
    func importPicture() {
        self.showImagePicker.toggle()
    }
    
    func animatePath() {
        self.pathTrim = 1
        // Path out of border
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeOut(duration: 0.8)) {
                self.pathTrim = 0
            }
        }
    }
    
    func setSize(_ width: Int, _ height: Int) {
        let changed = self.imgCtrl.setWidthHeight(width, height)
        if changed {
            self.animatePath()
            self.rigidGenerator.impactOccurred()
        }
    }
    
    func incrementHeight() {
        self.setSize(self.imgCtrl.width, self.imgCtrl.height + 1)
    }
    
    func decrementHeight() {
        self.setSize(self.imgCtrl.width, self.imgCtrl.height - 1)
    }
    
    func incrementWidth() {
        self.setSize(self.imgCtrl.width + 1, self.imgCtrl.height)
    }
     
     func decrementWidth() {
        self.setSize(self.imgCtrl.width - 1, self.imgCtrl.height)
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
                    x: Int(self.imgCtrl.gridWidth),
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
        
        //  wpath = path.scale(-1).path(in: path.boundingRect)
        
        return path
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
