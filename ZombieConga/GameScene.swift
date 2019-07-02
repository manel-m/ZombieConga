//
//  GameScene.swift
//  ZombieConga
//
//  Created by Manel matougui on 6/27/19.
//

import SpriteKit
class GameScene: SKScene {
    // Initialize or create the sprite
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    // the zombie should move 480 points in 1 second
    let zombieMovePointsPerSec: CGFloat = 480.0
    // 2D vector
    var velocity = CGPoint.zero
    let playableRect: CGRect
    var lastTouchLocation : CGPoint?
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight) // 4
        super.init(size: size) // 5
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 6
    }
    //helper method to draw playable rectangle
    func debugDrawPlayableArea() {
        let shape = SKShapeNode(rect: playableRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
//(1)create the sprite
        let background = SKSpriteNode(imageNamed: "background1")
        // rotate the sprite
       // background.zRotation = CGFloat.pi / 8
        //sprite size
       // let mySize = background.size
        //print("Size: \(mySize)")
//(2) Position the sprite.
        //background.anchorPoint = CGPoint.zero
        //background.position = CGPoint.zero
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
        background.position = CGPoint(x: size.width/2, y: size.height/2)
// (3) Optionally set the sprite’s z-position. but necessary for background
        background.zPosition = -1
 //(4) Add the sprite to the scene graph.
        addChild(background)
        
        zombie.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
        zombie.position = CGPoint(x: 400, y: 400)
        //zombie.setScale(2)
        addChild(zombie)
        spawnEnemy()
        debugDrawPlayableArea()
        // Gesture recognizer example
        //    // Uncomment this and the handleTap method, and comment the touchesBegan/Moved methods to test
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//        view.addGestureRecognizer(tapRecognizer)
//
//    }
//     @objc func handleTap(recognizer: UIGestureRecognizer) {
//       let viewLocation = recognizer.location(in: self.view)
//       let touchLocation = convertPoint(fromView: viewLocation)
//        sceneTouched(touchLocation: touchLocation)
       }
    
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0 }
        lastUpdateTime = currentTime
        print("\(dt*1000) milliseconds since last update")
// (phase 1)A fixed distance per frame
        //zombie.position = CGPoint(x: zombie.position.x + 8, y:zombie.position.y)
 // (phase 2) Using delta time for smooth velocity (zombieMovePointsPerSec)
        
        if let lastTouchLocation = lastTouchLocation {
            let diff = lastTouchLocation - zombie.position
            if  diff.length() <= zombieMovePointsPerSec * CGFloat(dt){
                zombie.position = lastTouchLocation
                velocity = CGPoint.zero
            } else {
                move(sprite: zombie,velocity: velocity)
                rotate(sprite: zombie, direction: velocity,rotateRadiansPerSec: zombieRotateRadiansPerSec)
            }
        }
        boundsCheckZombie()
    }
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
        let topRight = CGPoint(x: size.width, y: playableRect.maxY)
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        // 1
        //let amountToMove = CGPoint(x: velocity.x * CGFloat(dt),y: velocity.y * CGFloat(dt))
        let amountToMove = velocity * CGFloat(dt)
        print("Amount to move: \(amountToMove)")
        // 2
        //sprite.position = CGPoint(x: sprite.position.x + amountToMove.x, y: sprite.position.y + amountToMove.y)
        sprite.position += amountToMove
    }
    func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        //sprite.zRotation = atan2(direction.y, direction.x)
        //sprite.zRotation = direction.angle
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(x: size.width + enemy.size.width/2 , y: size.height/2)
        addChild(enemy)
        let actionMove = SKAction.move(
            to: CGPoint(x: -enemy.size.width/2, y: enemy.position.y),
            duration: 5.0)
        enemy.run(actionMove)
    }
    
    func moveZombieToward(location: CGPoint) {
        //let offset = CGPoint(x: location.x - zombie.position.x,y: location.y - zombie.position.y)
        let offset = location - zombie.position
//        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
//        let direction = CGPoint(x: offset.x / CGFloat(length),
//                                y: offset.y / CGFloat(length))
        let direction = offset.normalized()
//        velocity = CGPoint(x: direction.x * zombieMovePointsPerSec,
//                           y: direction.y * zombieMovePointsPerSec)
        velocity = direction * zombieMovePointsPerSec
    }
    
    
    func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
        moveZombieToward(location: touchLocation)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
   
}
