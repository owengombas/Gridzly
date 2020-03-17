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

    var body: some View {
        VStack {
            ZStack {
                Image("Image")
                    .antialiased(true)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                getPath()
                    .stroke(Color.white, lineWidth: 1)
                    .opacity(0.3)
            }
            .frame(
                width: CGFloat(ImageController.instance.viewImageWidth),
                height: CGFloat(ImageController.instance.viewImageHeight),
                alignment: .center
            )
            .onTapGesture {
                // ImagePicker
            }

            VStack {
                Stepper(
                    onIncrement: self.incrementHeight,
                    onDecrement: self.decrementHeight
                ) {
                    Text("vertical ")
                    .font(.custom("Metropolis-medium", size: 23))
                    Text("\(height)")
                    .font(.custom("Metropolis-bold", size: 23))
                }
                Stepper(
                    onIncrement: self.incrementWidth,
                    onDecrement: self.decrementWidth
                ) {
                    Text("horizontal ")
                    .font(.custom("Metropolis-medium", size: 23))
                    Text("\(width)")
                    .font(.custom("Metropolis-bold", size: 23))
                }
            }.padding(20)
            
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
    
    func save() {
        ImageController.instance.save()
    }
    
    func incrementWidth() {
        self.width += 1
    }
    
    func decrementWidth() {
        self.width -= 1
    }
    
    func incrementHeight() {
        self.height += 1
    }
    
    func decrementHeight() {
        self.height -= 1
    }
    
    func updateGrid() {
        ImageController.instance.width = self.width
        ImageController.instance.height = self.height
    }
    
    func getPath() -> Path {
        updateGrid()
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
