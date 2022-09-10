//
//  Point.swift
//  Freehand
//
//  Created by John Knowles on 9/9/22.
//

import Foundation

extension PerfectFreehand {
    struct Point {
        // horizontal coordinate
        let x: Double
        // vertical coordinate
        let y: Double
        // pressure component
        let p: Double
        
        init(x: Double, y: Double, p: Double = 0.5) {
            self.x = x
            self.y = y
            self.p = p
        }
    }


}
extension PerfectFreehand.Point {
    func neg() -> PerfectFreehand.Point  {
        PerfectFreehand.Point (x: -self.x, y: -self.y, p: self.p)
    }
    
    func add(_ this: PerfectFreehand.Point ) -> PerfectFreehand.Point  {
        PerfectFreehand.Point (x: self.x + this.x, y: self.y + this.y, p: this.p)
    }
    
    func sub(_ this: PerfectFreehand.Point ) -> PerfectFreehand.Point  {
        PerfectFreehand.Point (x: self.x - this.x, y: self.y - this.y, p: this.p)
    }
    
    func mulV(_ this: PerfectFreehand.Point ) -> PerfectFreehand.Point  {
        PerfectFreehand.Point (x: self.x * this.x, y: self.y * this.y, p: this.p)
    }

    func mul(_ this: Double) -> PerfectFreehand.Point  {
        PerfectFreehand.Point (x: self.x * this, y: self.y * this, p: self.p)
    }
    
    func divV(_ this: PerfectFreehand.Point ) -> PerfectFreehand.Point  {
        PerfectFreehand.Point (x: self.x / this.x, y: self.y / this.y, p: this.p)
    }
    
    func div(_ this: Double) -> PerfectFreehand.Point  {
        PerfectFreehand.Point (x: self.x / this, y: self.y / this, p: self.p)
    }
    
    func per() -> PerfectFreehand.Point  {
        PerfectFreehand.Point (x: self.y, y: -self.x, p: self.p)
    }

    func uni() -> PerfectFreehand.Point  {
        self.div(self.len())

    }

    func lrp(_ this: PerfectFreehand.Point , t: Double) -> PerfectFreehand.Point  {
        self.add(this.sub(self).mul(t))
    }
    
    func med(_ this: PerfectFreehand.Point ) -> PerfectFreehand.Point  {
        self.lrp(this, t: 0.5)
    }
    
    func len() -> Double {
        sqrt(self.len2())
    }
    
    func len2() -> Double {
        self.x * self.x + self.y * self.y
    }
    
    
    func isEqual(_ this: PerfectFreehand.Point ) -> Bool {
        self.x == this.x && self.y == this.y
     }
    
    func dist2(_ this: PerfectFreehand.Point ) -> Double {
        self.sub(this).len2()
    }
    
    func dist(_ this: PerfectFreehand.Point ) -> Double {
        self.sub(this).len()
    }
    
    func dpr(_ this: PerfectFreehand.Point ) -> Double {
        self.x * this.x + self.y * this.y
    }

    func prj(_ this: PerfectFreehand.Point , d: Double) -> PerfectFreehand.Point  {
       self.add(this.mul(d))
    }
    
    func rotAround(_ this: PerfectFreehand.Point , r: Double) -> PerfectFreehand.Point  {
        let s = sin(r)
        let c = cos(r)
        let px = self.x - this.x
        let py = self.y - this.y
        let nx = px * c - py * s
        let ny = py * s + py * c
        return PerfectFreehand.Point (x: nx + this.x, y: ny + this.y, p: this.p)
    }
}

