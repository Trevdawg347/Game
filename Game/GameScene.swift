//
//  GameScene.swift
//  Game
//
//  Created by Wendy Buhler on 8/18/21.
//

import SpriteKit
import GameplayKit
import CoreMotion


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var label: SKLabelNode!
    var score: Int = 0

    var motionManager = CMMotionManager()
    var xAcceleration: CGFloat = 0
    
    var bulletCategory: UInt32 = 2
    var enemyCategory: UInt32 = 1
    var playerCategory: UInt32 = 3
    
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        // Player
        player = SKSpriteNode(color: .black, size: CGSize(width: 64, height: 64))
        player.position = CGPoint(x: self.size.width / 2, y: player.size.height + 20)
        self.addChild(player)
        
        // Move Player
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { data, error in
            self.xAcceleration = CGFloat((data?.acceleration.x)!)
        }
        
        // Enemy
        let wait = SKAction.wait(forDuration: 0.5)
        let add = SKAction.run { self.addEnemy() }
        let repeats = SKAction.repeatForever(SKAction.sequence([wait, add]))
        self.run(repeats)
        
        // Score
        label = SKLabelNode(text: "Score: \(score)")
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 20, y: self.size.height - 20)
        label.fontName = "Times New Roman"
        self.addChild(label)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            
            let location = touch.location(in: self)
            shoot(position: location)
            
        }
        
    }
    override func didSimulatePhysics() {
        player.position.x += xAcceleration * 50
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA.node as? SKSpriteNode
        let bodyB = contact.bodyB.node as? SKSpriteNode
        
        if bodyA?.name == "bullet" && bodyB?.name == "enemy" {
            bodyA?.removeFromParent()
            bodyB?.removeFromParent()
        } else if bodyA?.name == "enemy" && bodyB?.name == "bullet" {
            bodyA?.removeFromParent()
            bodyB?.removeFromParent()
        }
        addScore()
    }
    
    func addEnemy() {
        let enemy = SKSpriteNode(color: .red, size: CGSize(width: 64, height: 64))
        enemy.name = "enemy"
        enemy.position.y = self.size.height + enemy.size.height
        enemy.position.x = CGFloat.random(in: 0...375)
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.collisionBitMask = 0
        enemy.physicsBody?.contactTestBitMask = bulletCategory | playerCategory
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.affectedByGravity = false
        self.addChild(enemy)
        let move = SKAction.move(to: CGPoint(x: enemy.position.x, y: -enemy.size.height / 2), duration: 2)
        let remove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([move, remove]))
    }
    
    
    func shoot(position: CGPoint) {
        let bullet = SKSpriteNode(color: .yellow, size: CGSize(width: 5, height: 5))
        bullet.name = "bullet"
        bullet.position = CGPoint(x: player.position.x, y: player.position.y + player.size.height / 2)
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = enemyCategory
        bullet.physicsBody?.collisionBitMask = 0
        self.addChild(bullet)
        
        let move = SKAction.move(to: CGPoint(x: bullet.position.x, y: self.frame.height), duration: 1)
        let remove = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([move, remove]))
    }
    func addScore() {
        score += 1
        label.text = "Score: \(score)"
    }
    
}
