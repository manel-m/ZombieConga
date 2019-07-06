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
    let catMovePointsPerSec: CGFloat = 480.0
    // 2D vector
    var velocity = CGPoint.zero
    let playableRect: CGRect
    var lastTouchLocation : CGPoint?
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    let zombieAnimation: SKAction
    
    var invincible = false
    var lives = 5
    var gameOver = false
    
    let cameraNode = SKCameraNode()
    let cameraMovePointsPerSec: CGFloat = 200.0

    let catCollisionSound: SKAction = SKAction.playSoundFileNamed(
        "hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed(
        "hitCatLady.wav", waitForCompletion: false)
    
    var cameraRect : CGRect {
        let x = cameraNode.position.x - size.width/2
            + (size.width - playableRect.width)/2
        let y = cameraNode.position.y - size.height/2
            + (size.height - playableRect.height)/2
        return CGRect(
            x: x,
            y: y,
            width: playableRect.width,
            height: playableRect.height)
    }
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight) // 4
        // 1
        var textures:[SKTexture] = []
        // 2
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        // 3
        textures.append(textures[2])
        textures.append(textures[1])
        // 4
        zombieAnimation = SKAction.animate(with: textures,
                                           timePerFrame: 0.1)
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
//        backgroundColor = SKColor.black
////(1)create the sprite
//        let background = SKSpriteNode(imageNamed: "background1")
////(2) Position the sprite.
//        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
//        background.position = CGPoint(x: size.width/2, y: size.height/2)
//// (3) Optionally set the sprite’s z-position. but necessary for background
//        background.zPosition = -1
// //(4) Add the sprite to the scene graph.
//        addChild(background)
        
//        let background = backgroundNode()
//        background.anchorPoint = CGPoint.zero
//        background.position = CGPoint.zero
//        background.name = "background"
//        background.zPosition = -1
//        addChild(background)
        
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position =
                CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.name = "background"
            background.zPosition = -1
            addChild(background)
        }
        
        zombie.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
        zombie.position = CGPoint(x: 400, y: 400)
        zombie.zPosition = 100
        addChild(zombie)
        //zombie.run(SKAction.repeatForever(zombieAnimation))

        //debugDrawPlayableArea()
        
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnEnemy()
                }, SKAction.wait(forDuration: 5.0)])))
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnCat()
                },SKAction.wait(forDuration: 1.0)])))
        
        playBackgroundMusic(filename: "backgroundMusic.mp3")
        
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
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
        
//        if let lastTouchLocation = lastTouchLocation {
//            let diff = lastTouchLocation - zombie.position
//            if  diff.length() <= zombieMovePointsPerSec * CGFloat(dt){
//                zombie.position = lastTouchLocation
//                velocity = CGPoint.zero
//                stopZombieAnimation()
//            } else {
                move(sprite: zombie,velocity: velocity)
                rotate(sprite: zombie, direction: velocity,rotateRadiansPerSec: zombieRotateRadiansPerSec)
//            }
//        }
        boundsCheckZombie()
        moveTrain()
        moveCamera()
        if lives <= 0 && !gameOver {
            gameOver = true
            print("You lose!")
            backgroundMusicPlayer.stop()
            // 1
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            // 2
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            // 3
            view?.presentScene(gameOverScene, transition: reveal)
        }
        //checkCollisions()
        //cameraNode.position = zombie.position
    }
    override func didEvaluateActions() {
        checkCollisions()
    }
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
        let topRight = CGPoint(x: cameraRect.maxX, y: cameraRect.maxY)
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = abs(velocity.x)
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
        //print("Amount to move: \(amountToMove)")
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
    func startZombieAnimation() {
        if zombie.action(forKey: "animation") == nil {
            zombie.run(
                SKAction.repeatForever(zombieAnimation),
                withKey: "animation")
        } }
    func stopZombieAnimation() {
        zombie.removeAction(forKey: "animation")
    }
    
    func moveZombieToward(location: CGPoint) {
        startZombieAnimation()
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
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.position = CGPoint(
            x: cameraRect.maxX + enemy.size.width/2,
            y: CGFloat.random(
                min: cameraRect.minY + enemy.size.height/2,
                max: cameraRect.maxY - enemy.size.height/2))
        enemy.zPosition = 50
        addChild(enemy)
        let actionMove =
            SKAction.moveTo(x:cameraRect.minX - enemy.size.width/2, duration:2.0)
        //SKAction.moveBy(x: -(size.width + enemy.size.width), y: 0, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
    }
    func spawnCat() {
        // 1
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(
            x: CGFloat.random(min: cameraRect.minX,
                              max: cameraRect.maxX),
            y: CGFloat.random(min: cameraRect.minY,
                              max: cameraRect.maxY))
        cat.zPosition = 50
        cat.setScale(0)
        addChild(cat)
        // 2
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        cat.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotate(byAngle: π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence(
            [scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeat(group, count: 10)
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.run(SKAction.sequence(actions))
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
    
    func zombieHit(cat: SKSpriteNode) {
        //cat.removeFromParent()
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1.0)
        cat.zRotation = 0
        let colorAction = SKAction.colorize(with: SKColor.green, colorBlendFactor: 1.0, duration: 0.2)
        cat.run(colorAction)
        
        
        run(catCollisionSound)
    }
    func moveTrain() {
        var trainCount = 0
        var targetPosition = zombie.position
        enumerateChildNodes(withName: "train") { node, stop in
            trainCount += 1

            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction * self.catMovePointsPerSec
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration)
                    node.run(moveAction)
            }
            targetPosition = node.position
        }
        if trainCount >= 15 && !gameOver {
            gameOver = true
            print("You win!")
            backgroundMusicPlayer.stop()
            // 1
            let gameOverScene = GameOverScene(size: size, won : true)
            gameOverScene.scaleMode = scaleMode
            // 2
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            // 3
            view?.presentScene(gameOverScene, transition: reveal)
        }
        
    }
    func loseCats() {
        // 1
        var loseCount = 0
        enumerateChildNodes(withName: "train") { node, stop in
            // 2
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            // 3
            node.name = ""
            node.run(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.rotate(byAngle: π*4, duration: 1.0),
                        SKAction.move(to: randomSpot, duration: 1.0),
                        SKAction.scale(to: 0, duration: 1.0)
                        ]),SKAction.removeFromParent()
                    ]))
            // 4
            loseCount += 1
            if loseCount >= 2 {
                stop[0] = true
            }
        } }
    
    
    func zombieHit(enemy: SKSpriteNode) {
        invincible = true
        //enemy.removeFromParent()
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(
        withDuration: duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(
                dividingBy: slice)
            node.isHidden = remainder > slice / 2
            
        }
        
        let setHidden = SKAction.run(){ [weak self] in
            self?.zombie.isHidden = false
            self?.invincible = false
        }
//        let finishAction = SKAction.customAction(
//        withDuration: 0) { node, elapsedTime in
//            self.zombie.isHidden = false
//            self.invincible = false
//        }
        zombie.run(SKAction.sequence([blinkAction, setHidden]))
        run(enemyCollisionSound)
        loseCats()
        lives -= 1
    }
    
    func checkCollisions() {
        
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodes(withName: "cat") { node, _ in
            let cat = node as! SKSpriteNode
            if cat.frame.intersects(self.zombie.frame) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHit(cat: cat)
        }

        if invincible == false {
            var hitEnemies: [SKSpriteNode] = []
            enumerateChildNodes(withName: "enemy") { node, _ in
                let enemy = node as! SKSpriteNode
                if node.frame.insetBy(dx: 20, dy: 20).intersects(
                    self.zombie.frame) {
                    hitEnemies.append(enemy)
                }
            }
            for enemy in hitEnemies {
                zombieHit(enemy: enemy)
            }
        }
       
    }
    
    func backgroundNode() -> SKSpriteNode {
        // 1
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        // 2
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        // 3
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position =
            CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        // 4
        backgroundNode.size = CGSize(
            width: background1.size.width + background2.size.width,
            height: background1.size.height)
        return backgroundNode
    }
    
    func moveCamera() {
        let backgroundVelocity =
            CGPoint(x: cameraMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        cameraNode.position += amountToMove
        
        enumerateChildNodes(withName: "background") { node, _ in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width <
                self.cameraRect.origin.x {
                background.position = CGPoint(
                    x: background.position.x + background.size.width*2,
                    y: background.position.y)
            }
        }
        
    }
   
}
