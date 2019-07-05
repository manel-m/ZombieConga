//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by Manel matougui on 7/4/19.
//

import Foundation
import SpriteKit

class MainMenuScene : SKScene {
    
    override func didMove(to view: SKView) {
        var background: SKSpriteNode
        background = SKSpriteNode(imageNamed: "MainMenu")
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        let transition = SKTransition.doorway(withDuration: 1.5)
        let nextScene = GameScene(size: size)
        nextScene.scaleMode = scaleMode
        view?.presentScene(nextScene, transition: transition)
    }
}
