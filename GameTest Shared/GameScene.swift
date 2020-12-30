//
//  GameScene.swift
//  GameTest Shared
//
//  Created by Julio César Fernández Muñoz on 26/12/20.
//

import SpriteKit

class GameScene: SKScene {
    
    var isMoving = false
    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    func setUpScene() {
        
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(salto(_:)))
        gesture.direction = .up
        self.view?.addGestureRecognizer(gesture)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let aventura = self.childNode(withName: "Aventurer") as? SKSpriteNode,
              let advRun = SKAction(named: "AdvRun"),
              !isMoving else {
            return
        }
        let position = touch.location(in: self)
        if aventura.position.x > position.x {
            aventura.xScale = -1
        } else {
            aventura.xScale = 1
        }
        let actionMove = SKAction.move(to: position, duration: 1)
        actionMove.timingMode = .easeInEaseOut
        let moveRun = SKAction.group([advRun, actionMove])
        isMoving = true
        aventura.run(moveRun) { self.isMoving = false }
    }
    @objc func salto(_ gesture:UISwipeGestureRecognizer) {
        guard let aventura = self.childNode(withName: "Aventurer") as? SKSpriteNode,
              let advJump = SKAction(named: "AdvJump") else {
            return
        }
        let saltoMov1 = SKAction.moveTo(y: aventura.position.y + 50, duration: 0.4)
        let saltoMov2 = SKAction.moveTo(y: aventura.position.y, duration: 0.4)
        let secuenciaMov = SKAction.sequence([
            saltoMov1, saltoMov2
        ])
        secuenciaMov.timingMode = .easeInEaseOut
        let jump = SKAction.group([
            advJump, secuenciaMov
        ])
        isMoving = true
        aventura.run(jump) { self.isMoving = false }    }
}

#if os(OSX)

// Mouse-based event handling
extension GameScene {
    
}
#endif

