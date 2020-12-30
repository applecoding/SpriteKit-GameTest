//
//  GameScene.swift
//  GameTest Shared
//
//  Created by Julio César Fernández Muñoz on 26/12/20.
//

import SpriteKit

class GameScene: SKScene {
    
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
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let aventura = self.childNode(withName: "Aventurer") as? SKSpriteNode,
              let advRun = SKAction(named: "AdvRun"),
              let advJump = SKAction(named: "AdvJump") else {
            return
        }
        let position = touch.location(in: self)
        if touch.tapCount == 1 {
            if aventura.position.x > position.x {
                aventura.xScale = -1
            } else {
                aventura.xScale = 1
            }
            let actionMove = SKAction.move(to: position, duration: 1)
            actionMove.timingMode = .easeInEaseOut
            let moveRun = SKAction.group([advRun, actionMove])
            aventura.run(moveRun)
        } else if touch.tapCount == 2 {
            let saltoMov1 = SKAction.moveTo(y: aventura.position.y + 50, duration: 0.4)
            let saltoMov2 = SKAction.moveTo(y: aventura.position.y - 50, duration: 0.4)
            let secuenciaMov = SKAction.sequence([
                saltoMov1, saltoMov2
            ])
            secuenciaMov.timingMode = .easeInEaseOut
            let jump = SKAction.group([
                advJump, secuenciaMov
            ])
            aventura.run(jump)
        }
    }
    
}

#if os(OSX)

// Mouse-based event handling
extension GameScene {

}
#endif

