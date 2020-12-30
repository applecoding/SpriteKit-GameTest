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
}

#if os(OSX)

// Mouse-based event handling
extension GameScene {

}
#endif

