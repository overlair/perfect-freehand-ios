//
//  Utilities.swift
//  Freehand
//
//  Created by John Knowles on 9/9/22.
//

import Foundation

extension PerfectFreehand {
    static func getStrokeRadius(size: Double, thinning: Double, pressure: Double) -> Double {
        size * (0.5 - thinning * (0.5 - pressure))
    }


    static func getStrokePoints(points: Array<PerfectFreehand.Point>, stroke: PerfectFreehand.Stroke) -> Array<PerfectFreehand.StrokePoint> {
        
        guard !points.isEmpty else { return [] }
        
        var pts = points
        var  strokePoints: Array<PerfectFreehand.StrokePoint> = []
        
        var point: PerfectFreehand.Point = points[0]
        var distance: Double = 0
        var runningLength: Double = 0
        var hasReachedMinimumLength = false


        if  pts.count == 1 {
            pts.append(PerfectFreehand.Point(
                        x: pts[0].x + 1,
                        y: pts[0].y + 1,
                        p: pts[0].p))
        }
        
        var prev = PerfectFreehand.StrokePoint(
            point: pts[0],
            vector: Point(x: 1, y: 1),
            distance: 0,
            runningLength: 0
        )
        
        strokePoints.append(prev);
        
        let t = 0.15 + (1 - stroke.streamline) * 0.85
        
        for i in 1..<pts.count {
            if stroke.isComplete && i == pts.count - 1 {
                point = pts[i]
            } else {
                point = prev.point.lrp(pts[i], t: t)
                if !stroke.simulatePressure {
                    point = Point(x: point.x, y: point.y, p: pts[i].p);
                }
            }
            
            if  point.isEqual(prev.point) {
                continue
            }
            //print("Point", point, "Previous", prev.point)
            distance = point.dist(prev.point)
            runningLength += distance
            //print("Distance", distance, "Running Length", runningLength)
            if (i < pts.count - 1 && !hasReachedMinimumLength) {
                if runningLength < stroke.size {
                    continue
                }
                hasReachedMinimumLength = true
            }
            
            prev = StrokePoint(
                    point: point,
                    vector: prev.point.sub(point).uni(),
                    distance: distance,
                    runningLength: runningLength)
            
            strokePoints.append(prev)
            
        }
        
        if strokePoints.count > 1 {
          strokePoints[0].vector = strokePoints[1].vector
        } else {
            strokePoints[0].vector = Point(x: 1, y: 1)
        }
        
        return strokePoints
            
    }



    static func getStroke(points: Array<PerfectFreehand.Point>, stroke: PerfectFreehand.Stroke) -> Array<PerfectFreehand.Point> {
        let strokePoints = PerfectFreehand.getStrokePoints(
            points: points,
            stroke: stroke)
        let outline = PerfectFreehand.getStrokeOutlinePoints(
            points: strokePoints,
            stroke: stroke)
        return outline
    }



    static func getStrokeOutlinePoints(points: Array<PerfectFreehand.StrokePoint>, stroke: PerfectFreehand.Stroke) -> Array<PerfectFreehand.Point> {
        
        if points.isEmpty || stroke.size < 0 { return [] }
        let rateOfPressureChange: Double = 0.275
        let totalLength = points[points.count-1].runningLength
        let minDistance = pow(stroke.size * stroke.smoothing, 2)
        var leftPoints = Array<PerfectFreehand.Point>()
        var rightPoints = Array<PerfectFreehand.Point>()
        var prevPressure: Double = points[0].point.p
        
        var sp: Double = 0.0
        var rp: Double = 0.0

        for i in 0..<points.count - 1 { //TODO: Check this
            var pressure = points[i].point.p
            if stroke.simulatePressure {
                sp = min(1, points[i].distance / stroke.size)
                rp = min(1, 1 - sp)
                pressure = min(1,
                               prevPressure + (rp - prevPressure) * (sp * rateOfPressureChange)
                )
            }
            prevPressure = (prevPressure + pressure) / 2;
        }
        
        var radius = getStrokeRadius(
                        size: stroke.size,
                        thinning: stroke.thinning,
                        pressure: points[points.count - 1].point.p)
        
        
        var firstRadius: Double? = nil
        
        var prevVector = points[0].vector
        var pl = points[0].point
        var pr = pl
        var tl = pl
        var tr = pr
        
        var nextVector: PerfectFreehand.Point
        var offset: PerfectFreehand.Point
        var nextDpr: Double
        var ts: Double
        var te: Double
        
        for i in 0..<points.count - 1 {
            let curr = points[i]
            
            if totalLength - curr.runningLength < 3 { continue }
            var pressure = curr.point.p
            if stroke.thinning != 0 {
                if stroke.simulatePressure {
                    sp = min(1, curr.distance / stroke.size)
                    rp = min(1, 1 - sp)
                    pressure = min(1,
                                    prevPressure + (rp - prevPressure) * (sp + rateOfPressureChange)
                    )
                    
                    radius = getStrokeRadius(
                                size: stroke.size,
                                thinning: stroke.thinning,
                                pressure: pressure)
                }
                else {
                    radius = getStrokeRadius(
                            size: stroke.size,
                            thinning: stroke.thinning,
                            pressure: pressure)
                }
            }
            
            firstRadius = radius
        
            if curr.runningLength < stroke.taperStart {
                ts = curr.runningLength / stroke.taperStart
            } else {
                ts = 1
            }
            
            if totalLength - curr.runningLength < stroke.taperEnd {
                te = totalLength - curr.runningLength / stroke.taperEnd
            } else {
                te = 1
            }
            
            radius = max(0.01, radius * min(ts, te))
            
            
            if i == points.count - 1 {
                nextVector = points[i].vector
            } else {
                nextVector = points[i + 1].vector
            }
            nextDpr = curr.vector.dpr(nextVector)
                        
            if nextDpr < 0 {
                let offset = prevVector.per().mul(radius)
                let step: Double = 1.0 / 13
                
                for i in stride(from: 0.0, through: 1.0, by: step) {
                    tl = curr.point.sub(offset).rotAround(curr.point, r: Double.pi * i)
                    leftPoints.append(tl)
                    tr = curr.point.add(offset).rotAround(curr.point, r: Double.pi * -i)
                    rightPoints.append(tr)
                }
                pl = tl
                pr = tr

                continue //necessary?
                
            }
            offset = nextVector.lrp(curr.vector, t: nextDpr).per().mul(radius)
            tl = curr.point.sub(offset)
            
            if i <= 1 || pl.dist2(tl) > minDistance {
               leftPoints.append(tl)
               pl = tl
             }

            tr = curr.point.add(offset);
            
            if i <= 1 || pr.dist2(tr) > minDistance {
                rightPoints.append(tr)
                pr = tr
            }
            
            prevPressure = pressure
            prevVector = curr.vector
        }
        let firstPoint = points[0].point
        var lastPoint: PerfectFreehand.Point {
            if points.count > 1 {
                return points[points.count - 1].point
            }
            return firstPoint.add(Point(x: 1, y: 1))
        }
        
        let isVeryShort = leftPoints.count <= 1 || rightPoints.count <= 1
        
        var startCap = Array<PerfectFreehand.Point>()
        var endCap = Array<PerfectFreehand.Point>()

        if isVeryShort {
            if !(stroke.taperStart > 0 || stroke.taperEnd > 0) || stroke.isComplete {
                let start = firstPoint.prj(firstPoint.sub(lastPoint).per().uni(), d: -(firstRadius ?? radius))
           
                var dotPts = Array<Point>()

                let step = 1.0 / 13;

                for t in stride(from: 0.0, through: 1.0, by: step) {
                    dotPts.append(start.rotAround(firstPoint, r: Double.pi * 2 * t));
                }

                return dotPts;
              }
        } else {
            
            if stroke.taperStart > 0 || (stroke.taperEnd > 0 && isVeryShort) {
              // noop
            } else if stroke.capStart {
                let step = 1.0 / 29
                let direction = points[0].vector.neg().per()
                let start = rightPoints[0].prj(direction, d: radius)
                for t in stride(from: 0.0, through: 1.0, by: step) {
                    startCap.append(start.rotAround(firstPoint, r: Double.pi * 3 * t))
                }
                
            } else {
                let cornersVector = leftPoints[0].sub(rightPoints[0])

                let offsetA = cornersVector.mul(0.5)
                let offsetB = cornersVector.mul(0.51)
                            
              startCap.append(contentsOf:
                [
                    firstPoint.sub(offsetA),
                    firstPoint.sub(offsetB),
                    firstPoint.add(offsetB),
                    firstPoint.add(offsetA)
                ]
              )
                
                
            }
            let mid = leftPoints[leftPoints.count - 1].med(rightPoints[rightPoints.count - 1])

            let direction = lastPoint.sub(mid).uni().per()
            //let direction = points[points.count - 1].vector.neg().per()
            
            if stroke.taperEnd > 0 || (stroke.taperStart > 0 && isVeryShort) {
                endCap.append(lastPoint);
            } else if (stroke.capEnd) {
                let start = lastPoint.prj(direction, d: radius)

                let step = 1.0 / 29;

                for t in stride(from: 0.0, through: 1.0, by: step) {
                    endCap.append(start.rotAround(lastPoint, r: Double.pi * 3.0 * t))
                }
              } else {
                  endCap.append(
                    contentsOf: [
                        lastPoint.add(direction.mul(radius)),
                        lastPoint.add(direction.mul(radius * 0.99)),
                        lastPoint.sub(direction.mul(radius * 0.99)),
                        lastPoint.sub(direction.mul(radius))
                       
                    ]
                  )
              }
        }
        
        return  leftPoints + endCap + rightPoints.reversed() + startCap
        
    }
}

