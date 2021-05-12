//
//  ActivityIndicator.swift
//  serialDetector (macOS)
//
//  Created by Kyryl Horbushko on 22.04.2021.
//

import SwiftUI

struct ActivityIndicator: View {
  @State private var isAnimating: Bool = false
  
  var body: some View {
    GeometryReader { geometry in
      ForEach(0..<5) { index in
        Group {
          
          let scaleForNonAnimated = 1 - CGFloat(index) / 5
          let scaleForAnimated = 0.2 + CGFloat(index) / 5
          let scale = isAnimating ? scaleForAnimated : scaleForNonAnimated
          
          Circle()
            .frame(width: geometry.size.width / 5, height: geometry.size.height / 5)
            .scaleEffect(scale)
            .offset(y: geometry.size.width / 10 - geometry.size.height / 2)
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .rotationEffect(isAnimating ? .degrees(360) : .zero)
        .animation(Animation
                    .timingCurve(0.5, 0.15 + Double(index) / 5, 0.25, 1, duration: 1.5)
                    .repeatForever(autoreverses: false))
      }
    }
    .aspectRatio(1, contentMode: .fit)
    .onAppear {
      self.isAnimating = true
    }
  }
  
}

struct ActivityIndicator_Previews: PreviewProvider {
  static var previews: some View {
    ActivityIndicator()
//      .frame(width: 250, height: 250)
      .foregroundColor(.blue)
  }
}
