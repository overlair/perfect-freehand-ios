//
//  ContentView.swift
//  Freehand
//
//  Created by John Knowles on 9/9/22.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @State var scene = GameScene(size: CGSize())

    var body: some View {
        GeometryReader { geo in
            
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .onAppear {
                    scene.size = geo.size
                   // scene.viewModel =
                }
                .overlay(alignment: .bottomTrailing) {
                    Button(action: { scene.clearStrokes() },
                           label: {
                        ZStack {
                            Circle().fill(.white).frame(width: 50, height: 50)
                            Image(systemName: "xmark")
                        }
                    }).padding(16)
                }
        }
       
    }
}

class GameScene: SKScene {
    
    override func sceneDidLoad() {
        print("sceneDidLoad:")
    }
    override func didMove(to view: SKView) {
        print("didMove:")
        view.isMultipleTouchEnabled = true
        
    }
    
    var strokes: [UUID: SKShapeNode] = [:]
    var stroke = PerfectFreehand.Stroke()
    var currentStrokeID: UUID? = nil
    var currentStroke: [PerfectFreehand.Point] = []
    
        let colors = [
            UIColor.systemPink,
            UIColor.purple,
            UIColor.systemCyan,
            UIColor.systemMint,
            UIColor.systemTeal,
            UIColor.systemGreen,
            UIColor.systemOrange,
        
        ]
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           // print("Began: \(touches.count)")
           //print(touches)
            stroke = PerfectFreehand.Stroke()
            let id = UUID()
            let color = colors.randomElement() ?? colors[0]
        
            let newStroke = SKShapeNode()
            newStroke.name = "stroke" + id.uuidString
            newStroke.strokeColor = color
            newStroke.lineWidth = stroke.size
            newStroke.lineCap = .round
            newStroke.lineJoin = .round
            newStroke.fillColor = color
        newStroke.glowWidth = 1.0

            strokes[id] = newStroke
            currentStrokeID = id
            addChild(newStroke)
        
        // start new stroke
       }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print("Moved: \(touches.count)")
        //print(touches)
        guard let id = currentStrokeID else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if let cTouches = event?.coalescedTouches(for: touch) {
            for cTouch in cTouches {
                let point = cTouch.location(in: self)
                currentStroke.append(PerfectFreehand.Point(x: point.x, y: point.y))
            }
        } else {
            currentStroke.append(PerfectFreehand.Point(x: location.x, y: location.y))
        }
       
        let freehand = PerfectFreehand.getStroke(points: currentStroke, stroke: stroke)
        //print(freehand)
        strokes[id]?.path = freehand.createPathFromStroke()
        //print(strokes[id]?.path)
        
        // add to new stroke
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("Ended: \(touches.count)")
//        print(touches)
        guard let id = currentStrokeID else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if let cTouches = event?.coalescedTouches(for: touch) {
            for cTouch in cTouches {
                let point = cTouch.location(in: self)
                currentStroke.append(PerfectFreehand.Point(x: point.x, y: point.y))
            }
        } else {
            currentStroke.append(PerfectFreehand.Point(x: location.x, y: location.y))
        }
        stroke.isComplete = true
        let freehand = PerfectFreehand.getStroke(points: currentStroke, stroke: stroke)
        //print(freehand)
        strokes[id]?.path = freehand.createPathFromStroke()
        
        
        // end current stroke
        currentStrokeID = nil
        currentStroke = []
    }
    
    
    public func clearStrokes() {
        for node in self.strokes.values {
            node.removeFromParent()
        }
        self.strokes = [:]
        
    }
}

