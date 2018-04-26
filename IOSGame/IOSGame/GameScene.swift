//
//  GameScene.swift
//  IOSGame
//
//  Created by teknologi game on 29/03/18.
//  Copyright © 2018 PENS. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let None : UInt32 = 0
    static let All : UInt32 = UInt32.max
    static let Monster : UInt32 = 0b1
    static let Projectile : UInt32 = 0b10
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var coins : Int = 0
    var ammo : Int = 50
    var ammoExists : Int = 1000
    let pemain = SKSpriteNode(imageNamed: "plane")
    var labelCoins = SKLabelNode()
    var labelAmmo = SKLabelNode()
    let shop = SKSpriteNode(imageNamed: "ammo")
    let upgrade = SKSpriteNode(imageNamed: "upgrade")
    var txtAmmoExists = SKLabelNode()
    var txtUpgrade = SKLabelNode()
    var upgradeNow = 0
    var ammoSize = 20.0
    var ammoSpeed = 0.5
    
    
    override func didMove(to view: SKView) {
        shop.position = CGPoint(x: size.width * 0.90, y: size.height * 0.080)
        shop.size.width = 50
        shop.size.height = 50
        addChild(shop)
        
        upgrade.position = CGPoint(x: size.width * 0.16, y: size.height * 0.080)
        upgrade.size.width = 50
        upgrade.size.height = 50
        addChild(upgrade)
        
        let txtShop = SKLabelNode()
        txtShop.fontSize = 15
        txtShop.fontColor = SKColor.black
        txtShop.fontName = "Avenir"
        txtShop.position = CGPoint(x: size.width * 0.85, y: size.height * 0.035)
        txtShop.text = "Buy 10 Ammo with 10 Coins"
        addChild(txtShop)
        
        txtUpgrade.fontSize = 15
        txtUpgrade.fontColor = SKColor.black
        txtUpgrade.fontName = "Avenir"
        txtUpgrade.position = CGPoint(x: size.width * 0.15, y: size.height * 0.035)
        txtUpgrade.text = "Upgrade Ammo"
        addChild(txtUpgrade)
        
        txtAmmoExists.fontSize = 35
        txtAmmoExists.fontColor = SKColor.black
        txtAmmoExists.fontName = "Avenir"
        txtAmmoExists.position = CGPoint(x: size.width * 0.81, y: size.height * 0.065)
        txtAmmoExists.text = String(ammoExists)
        addChild(txtAmmoExists)
        
        
        labelCoins.text = "Coins: " + String(coins)
        labelCoins.position = CGPoint(x: view.frame.width * 0.1, y: view.frame.height * 0.93)
        labelCoins.fontSize = 25
        labelCoins.fontColor = SKColor.black
        labelCoins.fontName = "Avenir"
        
        labelAmmo.text = "Ammo: " + String(ammo)
        labelAmmo.position = CGPoint(x: view.frame.width * 0.1, y: view.frame.height * 0.960)
        labelAmmo.fontSize = 25
        labelAmmo.fontColor = SKColor.black
        labelAmmo.fontName = "Avenir"
        
        addChild(labelCoins)
        addChild(labelAmmo)
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        backgroundColor = SKColor.white
        pemain.position = CGPoint(x: size.width * 0.5, y: size.height * 0.1)
        addChild(pemain)
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addAsteroid),
                SKAction.wait(forDuration: 1.0)
            ])
        ))
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addAsteroid() {
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        let actualX = random(min: asteroid.size.width / 2, max: size.width - asteroid.size.width / 2)
        asteroid.position = CGPoint(x: actualX, y: size.height + asteroid.size.height / 2)
        addChild(asteroid)
        asteroid.physicsBody = SKPhysicsBody(rectangleOf: asteroid.size)
        asteroid.physicsBody?.isDynamic = true
        asteroid.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        asteroid.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        asteroid.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        asteroid.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: actualX, y: asteroid.size.height / 2), duration: TimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        asteroid.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func buy_ammo() {
        ammo += 10
        labelAmmo.text = "Ammo: " + String(ammo)
        
        ammoExists -= 10
        txtAmmoExists.text = String(ammoExists)
        
        coins -= 10
        labelCoins.text = "Coins: " + String(coins)
    }
    
    func upgrade_ammo() {
        if(upgradeNow < 5) {
            upgradeNow += 1
            coins -= 50
            
            if(upgradeNow % 2 == 0) {
                ammoSpeed += 0.5
            }
            else {
                ammoSize += 20.0
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        
        
        if(shop.contains(touchLocation)) {
            if(coins >= 10 && ammoExists >= 5) {
                buy_ammo()
            }
        }
        else if(upgrade.contains(touchLocation)) {
            if(coins >= 50) {
                upgrade_ammo();
            }
        }
        else {
            if(ammo < 1) {
                return
            }
            else {
                let projectile = SKSpriteNode(imageNamed: "projectile")
                projectile.position = pemain.position
                
                projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
                projectile.physicsBody?.isDynamic = true
                projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
                projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
                projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
                projectile.physicsBody?.usesPreciseCollisionDetection = true
                
                let offset = touchLocation - projectile.position
                
                if(offset.y < 0) {
                    return
                }
                
                ammo -= 1
                labelAmmo.text = "Ammo: " + String(ammo)
                
                projectile.size.width = CGFloat(ammoSize)
                projectile.size.height = CGFloat(ammoSize)
                addChild(projectile)
                
                let direction = offset.normalized()
                let shootAmount = direction * 1000
                let realDest = shootAmount + projectile.position
                
                let actionMove = SKAction.move(to: realDest, duration: 2.0 - ammoSpeed)
                let actionMoveDone = SKAction.removeFromParent()
                projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
            }
        }
        
    }
    
    func projectileDidCollideWithAsteroid(projectile: SKSpriteNode, astr: SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
        astr.removeFromParent()
        
        //add score
        coins += 3
        labelCoins.text = "Coins: " + String(coins)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            if let astr = firstBody.node as? SKSpriteNode, let
                projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithAsteroid(projectile: projectile, astr: astr)
            }
        }
    }
}









