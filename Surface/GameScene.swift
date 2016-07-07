//
//  GameScene.swift
//  Surface
//
//  Created by Tsai Family on 7/5/16.
//  Copyright (c) 2016 MakeSchool. All rights reserved.
//

import SpriteKit

enum GameState {
    case Playing, GameOver
}

class GameScene: SKScene {
    var circle: SKSpriteNode!
    var scrollLayer: SKNode!
    var restart: MSButtonNode!
    let fixedDelta: CFTimeInterval = 1.0/60.0
    var scoreLabel: SKLabelNode!
    
    /* Creature Array */
    var gridArray = [[Square]]()
    
    /* Grid array dimensions */
    let rows = 14
    
    let side = 25
    
    var gridx = 600
    
    var randmove = 0
    
    var shouldmove = true
    
    var shifter = true
    
    var scrollSpeed: CGFloat = 80
    
    var moveSpeed: CGFloat = 3
    
    var goingUp = false
    
    var goingDown = false
    
    var scoreLevel = 35
    
    var state:GameState = .Playing
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = String(score)
        }
    }

    
    override func didMoveToView(view: SKView) {
        
        circle = childNodeWithName("circle") as! SKSpriteNode
        
        /* UI game objects */
        
        scrollLayer = self.childNodeWithName("scrollLayer")
        restart = self.childNodeWithName("restart") as! MSButtonNode
        
        scoreLabel = childNodeWithName("scoreLabel") as! SKLabelNode

        
        randmove = Int(arc4random_uniform(7))
        
        gridAdd(25)
        
        shifter = false
        
        restart.selectedHandler = {
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFill
            
            /* Restart game scene */
            skView.presentScene(scene)
            
            /* Hide restart button */
            
        }
        restart.state = .MSButtonNodeStateHidden
        
      
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        if state == .Playing{
        for touch in touches {
            let location  = touch.locationInNode(self)
            if location.x <= 284{
                if self.circle.position.y < 320{
                    goingUp = true
                    goingDown = false
                }
            }
            else{
                if self.circle.position.y > 0{
                    goingDown = true
                    goingUp = false
                }
            }
            
        }
    }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if state == .Playing{
            for touch in touches {
                let location  = touch.locationInNode(self)
                if location.x <= 284{
                    if self.circle.position.y < 320{
                        goingUp = false
                    }
                }
                else{
                    if self.circle.position.y > 0{
                        goingDown = false
                    }
                }
                
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if state == .GameOver{
        }
        else{
            if shouldmove{
                gridx -= Int(moveSpeed)
                moveGrid()
                scrollWorld()
                if goingUp && self.circle.position.y < 320{
                    self.circle.position.y += 4
                }
                else if goingDown && self.circle.position.y > 0{
                    self.circle.position.y -= 4
                }
            }
            if gridArray[0][0].position.x < -25{
                gridArray.removeAtIndex(0)
                gridAdd(1)
                gridx += Int(moveSpeed)
                score += 1
                if score % scoreLevel == 0 && score != 0 && moveSpeed < 9{
                    moveSpeed += 1
                    scrollSpeed += 10
                    scoreLevel += 35
                }
            }
            
            let currentpos = self.circle.position
        
            for scanx in 0..<5{
                for scany in 0..<13 {
                    let scanpos = gridArray[scanx][scany].position
                    let calculateddistance = sqrt(pow(Double(scanpos.x - currentpos.x),2.0) + pow(Double(scanpos.y - currentpos.y),2.0))
                    if calculateddistance < 37.5 && gridArray[scanx][scany].exists{
                        gameOver()
                    }
                
                }
            }
        }
    }
    
    func gridAdd(total: Int) {
        
        /* Loop through columns */
        for _ in 0..<total {
            
            /* Initialize empty column */
            gridArray.append([])
            
            /* Loop through rows */
            for gridY in 0 ..< 14 {
                
                let xpos = gridArray.count - 1
                
                if(gridY < randmove || gridY > randmove+5){
                
                    addCreatureAtGrid(x:xpos, y:gridY, shown: true)
                }
                else{
                    addCreatureAtGrid(x:xpos, y:gridY, shown: false)
                }
            }
            shiftRandMove()
        }
    }
    
    func moveGrid(){
        for gridX in 0..<gridArray.count {
            for gridY in 0..<gridArray[gridX].count {
                 gridArray[gridX][gridY].position.x -= moveSpeed
            }
            
        }
        
    }
    
    func shiftRandMove(){
        
        repeat{
            let change = Int(arc4random_uniform(3))
            switch change{
            case 0:
                randmove += 1
            case 1:
                randmove -= 1
            case 2:
                randmove += 0
            default:
                break
            }
        }
        while randmove < 0 || randmove > 7
    }
    
    func addCreatureAtGrid(x x: Int, y: Int, shown: Bool) {
        /* Add a new creature at grid position*/
        
        /* New creature object */
        
        let gridPosition: CGPoint
        let square = Square()
        
        if shown{
            square.exists = true
        }
        else{
            square.exists = false
        }
        
        if shifter{
        /* Calculate position on screen */
             gridPosition = CGPoint(x: x * side + gridx, y: y * side)
        }
        else{
             gridPosition = CGPoint(x: Int(gridArray[gridArray.count-2][1].position.x) + 25, y: y * side)
        }

            
        square.position = gridPosition
        
        /* Add creature to grid node */
        addChild(square)
        
        /* Add creature to grid array */
        gridArray[x].append(square)
    }
    
    func scrollWorld() {
        /* Scroll World */
        scrollLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through scroll layer nodes */
        for ground in scrollLayer.children as! [SKSpriteNode] {
            
            /* Get ground node position, convert node position to scene space */
            let groundPosition = scrollLayer.convertPoint(ground.position, toNode: self)
            
            /* Check if ground sprite has left the scene */
            if groundPosition.x <= -ground.size.width / 2 {
                
                /* Reposition ground sprite to the second starting position */
                let newPosition = CGPointMake( (self.size.width / 2) + ground.size.width, groundPosition.y)
                
                /* Convert new node position back to scroll layer space */
                ground.position = self.convertPoint(newPosition, toNode: scrollLayer)
            }
        }

    }
    
    func gameOver(){
        shouldmove = false
        restart.state = .MSButtonNodeStateActive
        state = .GameOver
    }

    
    
}
