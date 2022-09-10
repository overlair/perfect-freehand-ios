//
//  Draw.swift
//  Freehand
//
//  Created by John Knowles on 9/9/22.
//

import Foundation
import SpriteKit
import CoreGraphics

        
extension Array where Element == PerfectFreehand.Point {
    func createPathFromStroke() -> CGPath? {
        guard !self.isEmpty, let first = self.first else { return nil }
        let path = CGMutablePath()
        let _path = UIBezierPath()
        let points = self.map { CGPoint(x: $0.x, y: $0.y)}
        //var points: [CGPoint] = []
        
//        var prev = first
//        for point in self {
//            let step = 1.0 / 10
//            for t in stride(from: 0.0, through: 1.0, by: step) {
//                let tmp = prev.lrp(point, t: t)
//                points.append(CGPoint(x: tmp.x, y: tmp.y))
//            }
//            prev = point
//        }
        //path.move(to: CGPoint(x:first.x, y: first.y))
        _path.move(to: CGPoint(x:first.x, y: first.y))

//
//        var p1 = CGPoint(x:first.x, y: first.y)
//        var p2: CGPoint
//        for i in 0..<self.count - 2 {
//            p2 = points[i+1]
//            let midPoint = CGPoint(x: (p1.x + p2.x)/2.0, y: (p1.y + p2.y)/2.0)
//            path.addQuadCurve(to: p1, control: midPoint)
//            p1 = p2
//        }
//
        for p in points {
            _path.addLine(to: p)
        }
        //path.addLines(between: points)
    
       // path.closeSubpath()
        _path.lineJoinStyle = .round
        return _path.cgPath
    }
}
