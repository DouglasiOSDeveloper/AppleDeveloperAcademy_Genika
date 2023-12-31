//
//  RoundedTriangle.swift
//  Mini06-watchOSApp WatchKit Extension
//
//  Created by Vitor Souza on 09/06/22.
//

import SwiftUI

struct RoundedTriangle: Shape {
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let point0 = CGPoint(x: rect.midX / 2.0, y: rect.midY)
        let point1 = CGPoint(x: rect.minX, y: rect.maxY)
        let point2 = CGPoint(x: rect.midX, y: rect.minY)
        let point3 = CGPoint(x: rect.maxX, y: rect.maxY)
        
        path.move(to: point0)
        path.addArc(tangent1End: point2, tangent2End: point3, radius: cornerRadius)
        path.addArc(tangent1End: point3, tangent2End: point1, radius: cornerRadius)
        path.addArc(tangent1End: point1, tangent2End: point2, radius: cornerRadius)
        path.closeSubpath()
        
        return path
    }
}

struct RoundedTriangle_Previews: PreviewProvider {
    static var previews: some View {
        RoundedTriangle(cornerRadius: 20)
            .stroke(Color.blue, lineWidth: 10)
    }
}
