//
//  GameScene.swift
//  Surface
//
//  Created by Tsai Family on 7/5/16.
//  Copyright (c) 2016 MakeSchool. All rights reserved.
//

import SpriteKit

enum GameState {
    case playing, gameOver
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
    
    var gridy = -300
    
    var randmove = 0
    
    var shouldmove = true
    
    var shifter = true
    
    var scrollSpeed: CGFloat = 80
    
    var moveSpeed: CGFloat = 3
    
    var goingUp = false
    
    var goingDown = false
    
    var scoreLevel = 25
    
    var state:GameState = .playing
    
    var scoreCount = 0
    
    var highScore: Int = 0
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = String(score)
        }
    }

    
    override func didMove(to view: SKView) {
        
        circle = childNode(withName: "circle") as! SKSpriteNode
        
        /* UI game objects */
        
        scrollLayer = self.childNode(withName: "scrollLayer")
        restart = self.childNode(withName: "restart") as! MSButtonNode
        
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
       
        
        randmove = Int(arc4random_uniform(7))
        
        gridAdd(25)
        
        shifter = false
        
        restart.selectedHandler = {
            
            let tempHighScore = self.highScore
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene?.scaleMode = .aspectFill
            
            scene?.highScore = tempHighScore
            
            /* Restart game scene */
            skView?.presentScene(scene)
            
            
            /* Hide restart button */
            
        }
        restart.state = .msButtonNodeStateHidden
        
      
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        if state == .playing{
        for touch in touches {
            let location  = touch.location(in: self)
            if location.x <= 160{
                if self.circle.position.x < 320{
                    goingUp = true
                    goingDown = false
                }
            }
            else{
                if self.circle.position.x > 0{
                    goingDown = true
                    goingUp = false
                }
            }
            
        }
    }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if state == .playing{
            for touch in touches {
                let location  = touch.location(in: self)
                if location.x <= 160{
                    if self.circle.position.x < 320{
                        goingUp = false
                    }
                }
                else{
                    if self.circle.position.x > 0{
                        goingDown = false
                    }
                }
                
            }
        }
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        if state == .gameOver{
        }
        else{
            if shouldmove{
                gridy += Int(moveSpeed)
                moveGrid()
                if goingUp && self.circle.position.x > 25{
                    self.circle.position.x -= 4
                }
                else if goingDown && self.circle.position.x < 295{
                    self.circle.position.x += 4
                }
            }
            if gridArray[0][0].position.y > 600{
                gridArray.remove(at: 0)
                gridAdd(1)
                gridy -= Int(moveSpeed)
                score += 1
                scoreCount += 1
                if scoreCount % scoreLevel == 0 && score != 0 && moveSpeed < 11{
                    moveSpeed += 1
                    scrollSpeed += 15
                    scoreLevel += 25
                    scoreCount = 0
                }
            }
            scrollWorld()
            
            let currentpos = self.circle.position
        
            for scanx in 0..<7{
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
    
    func gridAdd(_ total: Int) {
        
        /* Loop through columns */
        for _ in 0..<total {
            
            /* Initialize empty row */
            gridArray.append([])
            
            /* Loop through rows */
            for gridX in 0 ..< 14 {
                
                let ypos = gridArray.count - 1
                
                if(gridX < randmove || gridX > randmove+5){
                    addCreatureAtGrid(x:gridX, y:ypos, shown: true)
                }
                else{
                    addCreatureAtGrid(x:gridX, y:ypos, shown: false)
                }
            }
            shiftRandMove()
        }
    }
    
    func moveGrid(){
        for gridX in 0..<gridArray.count {
            for gridY in 0..<gridArray[gridX].count {
                 gridArray[gridX][gridY].position.y += moveSpeed
            }
            
        }
        print(gridy)
        
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
    
    func addCreatureAtGrid(x: Int, y: Int, shown: Bool) {
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
             gridPosition = CGPoint(x: x * side, y: gridy -  y * side)      //the intialization
        }
        else{
             gridPosition = CGPoint(x: x * side, y: Int(gridArray[gridArray.count-2][0].position.y) - 25)   //adding on to grid
             print(gridPosition)
        }

            
        square.position = gridPosition
        
        /* Add creature to grid node */
        addChild(square)
        
        /* Add creature to grid array */
        gridArray[gridArray.count - 1].append(square)
    }
    
    func scrollWorld() {
        
        
        /* Scroll World */
        scrollLayer.position.y += scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through scroll layer nodes */
        for ground in scrollLayer.children as! [SKSpriteNode] {
            
            /* Get ground node position, convert node position to scene space */
            let groundPosition = scrollLayer.convert(ground.position, to: self)
            
            /* Check if ground sprite has left the scene */
            if groundPosition.y >= ground.size.height / 2 + ground.size.height{
                
                /* Reposition ground sprite to the second starting position */
                let newPosition = CGPoint( x: groundPosition.x, y: -(self.size.height / 2) + 5)
                
                /* Convert new node position back to scroll layer space */
                ground.position = self.convert(newPosition, to: scrollLayer)
            }
        }


    }
    
    func gameOver(){
        shouldmove = false
        if score > highScore{
            highScore = score
        }
        scoreLabel.fontSize = 40
        scoreLabel.text = "Score: " + String(score) + " High: " + String(highScore)
        restart.state = .msButtonNodeStateActive
        state = .gameOver
    }

    
    
}
