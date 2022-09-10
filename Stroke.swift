//
//  File.swift
//  Freehand
//
//  Created by John Knowles on 9/9/22.
//

import Foundation

extension PerfectFreehand {
    struct Stroke {
        var size: Double = 7
        var thinning: Double = 0.5
        var smoothing: Double = 0.8
        var streamline: Double = 0.5
        var taperStart: Double = 0.0
        var taperEnd: Double = 0.0
        var capStart: Bool = false
        var capEnd: Bool = false
        var simulatePressure: Bool = true
        var isComplete: Bool = false
    }
}
