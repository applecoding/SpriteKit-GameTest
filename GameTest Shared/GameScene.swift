//
//  GameScene.swift
//  GameTest Shared
//
//  Created by Julio César Fernández Muñoz on 26/12/20.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var musicPlayer:AVAudioPlayer!
    var ambientPlayer:AVAudioPlayer!
    
    var isMoving = false
    var isScroll = false
    
    var deltaTime:TimeInterval = 0
    var lastFrameTime:TimeInterval = 0
    
    var estado:EstadoAventurera = .quieta
    let nuevoEnemigo = GKRandomDistribution()
    
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
        guard let pathMusica = Bundle.main.url(forResource: "adventure_videogame", withExtension: "mp3"),
              let pathNight = Bundle.main.url(forResource: "night-forest", withExtension: "mp3") else {
            return
        }
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: pathMusica)
            musicPlayer.volume = 0.4
            musicPlayer.numberOfLoops = -1
            musicPlayer.play()
            ambientPlayer = try AVAudioPlayer(contentsOf: pathNight)
            ambientPlayer.volume = 0.9
            ambientPlayer.numberOfLoops = -1
            ambientPlayer.play()
        } catch {
            print("Error al crear el player de música \(error)")
        }
        
        guard let aventurera = childNode(withName: "Aventurer") as? SKSpriteNode else {
            return
        }
        aventurera.physicsBody = SKPhysicsBody(circleOfRadius: (aventurera.size.width / UIScreen.main.scale) / 3)
        aventurera.physicsBody?.categoryBitMask = Cuerpos.aventurera
        aventurera.physicsBody?.contactTestBitMask = Cuerpos.zombie
        aventurera.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        self.setUpScene()
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(salto(_:)))
        gesture.direction = .up
        self.view?.addGestureRecognizer(gesture)
        let scrollGesture = UISwipeGestureRecognizer(target: self, action: #selector(activaScroll(_:)))
        scrollGesture.direction = .left
        self.view?.addGestureRecognizer(scrollGesture)
        
        let newEnemy = SKAction.wait(forDuration: 2, withRange: 2)
        let shuffle = SKAction.run {
            self.shuffleEnemy()
        }
        self.run(.repeatForever(.sequence([newEnemy, shuffle])))
    }
    
    func shuffleEnemy() {
        if nuevoEnemigo.nextBool() {
            newZombie()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let aventura = self.childNode(withName: "Aventurer") as? SKSpriteNode,
              let ataca = SKAction(named: "AdvAtaca") else {
            return
        }
        let position = touch.location(in: self)
        if aventura.frame.contains(position) {
            var habiaScroll = false
            if isScroll {
                isScroll.toggle()
                habiaScroll = true
            }
            let knife = SKAction.playSoundFileNamed("knife.mp3", waitForCompletion: false)
            estado = .ataca
            aventura.run(SKAction.sequence([knife, ataca])) {
                if habiaScroll {
                    self.estado = .corre
                    self.isScroll.toggle()
                } else {
                    self.estado = .quieta
                }
            }
        }
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
        estado = .salta
        aventura.run(jump) {
            if self.isScroll {
                self.estado = .corre
            } else {
                self.estado = .quieta
            }
            self.isMoving = false
        }
    }
    
    @objc func activaScroll(_ gesture:UISwipeGestureRecognizer) {
        isScroll.toggle()
        if isScroll,
           let aventura = self.childNode(withName: "Aventurer") as? SKSpriteNode,
           let advRun = SKAction(named: "AdvRun") {
            aventura.run(advRun, withKey: "corriendo")
        }
        if !isScroll,
           let aventura = self.childNode(withName: "Aventurer") as? SKSpriteNode {
            aventura.removeAction(forKey: "corriendo")
        }
    }
    
    func moverLayer(layer:Int, tiempo:Float) {
        guard let fondo1 = childNode(withName: "layer\(layer)1") as? SKSpriteNode,
              let fondo2 = childNode(withName: "layer\(layer)2") as? SKSpriteNode else {
            return
        }
        var newPosition = CGPoint.zero
        for move in [fondo1, fondo2] {
            newPosition = move.position
            let control = CGFloat(tiempo * Float(deltaTime))
            newPosition.x -= control
            move.position = newPosition
            if move.frame.maxX < self.frame.minX {
                move.position = CGPoint(x: move.position.x + move.size.width * 2, y: move.position.y)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastFrameTime <= 0 {
            lastFrameTime = currentTime
        }
        deltaTime = currentTime - lastFrameTime
        lastFrameTime = currentTime
        if isScroll {
            moverLayer(layer: 1, tiempo: 70.0)
            moverLayer(layer: 2, tiempo: 80.0)
            moverLayer(layer: 3, tiempo: 90.0)
            moverLayer(layer: 4, tiempo: 100.0)
            moverLayer(layer: 5, tiempo: 110.0)
            moverLayer(layer: 6, tiempo: 120.0)
        }
    }
    
    func newZombie() {
        guard let aventurera = childNode(withName: "Aventurer") as? SKSpriteNode,
              let zombieWalk = SKAction(named: "ZombieWalk") else {
            return
        }
        let zombie = SKSpriteNode(imageNamed: "Walk (1)")
        zombie.position = CGPoint(x: self.frame.maxX + (zombie.frame.width * 2), y: aventurera.position.y)
        zombie.zPosition = aventurera.zPosition + 1
        zombie.xScale = -1
        addChild(zombie)
        let moveZombie = SKAction.moveTo(x: aventurera.position.x, duration: .random(in: 4...7))
        moveZombie.timingMode = .easeIn
        zombie.run(.group([moveZombie, zombieWalk,
                           .sequence([.wait(forDuration: .random(in: 1...3)), .playSoundFileNamed("groan\(Int.random(in: 1...5)).mp3", waitForCompletion: false)])
        ]))
        zombie.physicsBody = SKPhysicsBody(circleOfRadius: (zombie.size.width / UIScreen.main.scale) / 3)
        zombie.physicsBody?.categoryBitMask = Cuerpos.zombie
        zombie.physicsBody?.contactTestBitMask = Cuerpos.aventurera
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let deadZombie = SKAction(named: "ZombieDead") else {
            return
        }
        var aventura:SKPhysicsBody
        var zombie:SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            aventura = contact.bodyA
            zombie = contact.bodyB
        } else {
            aventura = contact.bodyB
            zombie = contact.bodyA
        }
        if estado == .ataca, let thezombie = zombie.node as? SKSpriteNode {
            thezombie.anchorPoint = CGPoint(x: 0.5, y: 0.6)
            thezombie.run(.sequence([
                .playSoundFileNamed("dying\(Int.random(in: 1...5)).mp3", waitForCompletion: false),
                deadZombie,
                .removeFromParent()
            ])) {
                aventura.node?.run(.moveTo(x: 0, duration: 1.0))
            }
        }
    }
    
    deinit {
        musicPlayer.stop()
        ambientPlayer.stop()
    }
}


#if os(OSX)

// Mouse-based event handling
extension GameScene {
    
}
#endif

/*
 
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
 
 */
