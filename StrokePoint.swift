//
//  StrokePoint.swift
//  Freehand
//
//  Created by John Knowles on 9/9/22.
//

import Foundation
extension PerfectFreehand {
    struct StrokePoint {
      // The point's x and y coordinates and pressure.
        let point: PerfectFreehand.Point

      // The vector between this point and the previous point.
        var vector: PerfectFreehand.Point

      // The distance from this point and the previous point.
        let distance: Double

      // The running length of the line at this point.
        let runningLength: Double
    }
}
