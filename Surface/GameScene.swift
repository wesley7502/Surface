//
//  GameScene.swift
//  Surface
//
//  Created by Tsai Family on 7/5/16.
//  Copyright (c) 2016 MakeSchool. All rights reserved.
//

import SpriteKit
import AVFoundation

enum GameState {
    case playing, gameOver, title
}

class GameScene: SKScene {
    var circle: SKSpriteNode!
    var scoreBackground: SKSpriteNode!
    var scrollLayer: SKNode!
    var restart: MSButtonNode!
    let fixedDelta: CFTimeInterval = 1.0/60.0
    var scoreLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    
    /* Creature Array */
    var gridArray = [[Square]]()
    
    /* Grid array dimensions */
    let rows = 14
    
    let side = 25
    
    var gridy = 600
    
    var randmove = 0
    
    var shouldmove = true
    
    var shifter = true
    
    var scrollSpeed: CGFloat = 80
    
    var moveSpeed: CGFloat = 5
    
    var movingTouch = false
    
    var scoreLevel = 3
    
    var state:GameState = .playing
    
    var scoreCount = 0
    
    var highScore: Int = 0
    
    var backgroundMusic: AVAudioPlayer!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = String(score)
        }
    }

    
    override func didMove(to view: SKView) {
        
        self.view?.showsFPS = false
        self.view?.showsNodeCount = false
        self.view?.showsDrawCount = false
        self.view?.showsFields = false
        
        circle = childNode(withName: "circle") as! SKSpriteNode
        scoreBackground = childNode(withName: "scoreBackground") as! SKSpriteNode
        scoreBackground.isHidden = true
        
        /* UI game objects */
        
        scrollLayer = self.childNode(withName: "scrollLayer")
        restart = self.childNode(withName: "restart") as! MSButtonNode
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        gameOverLabel = childNode(withName: "gameOverLabel") as! SKLabelNode
        gameOverLabel.isHidden = true
        
        
        randmove = Int(arc4random_uniform(7))
        
        gridAddBegin()
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
        
        let path = Bundle.main.path(forResource: "Berlin Impulse.mp3", ofType:nil)!   //background music
        let url = URL(fileURLWithPath: path)
        
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            backgroundMusic = sound
            sound.numberOfLoops = -1
            sound.play()
        } catch {
            // couldn't load file :(
        }

      
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        if state == .playing{
        for touch in touches {
            let location  = touch.location(in: self)
            movingTouch = true
            //let diffx: CGFloat = location.x - self.circle.position.x
            //let diffy: CGFloat = 0.0
            //let goTime = diffx/600
            //let move = SKAction.moveBy(x: diffx, y: diffy, duration: TimeInterval(goTime))
            //self.circle.run(move)
            self.circle.position.x = location.x
            
        }
    }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        if state == .playing{
            for touch in touches {
                let location = touch.location(in: self)
                circle.position.x = location.x
                
            }
        
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if state == .playing{
            for touch in touches {
                let location  = touch.location(in: self)
                movingTouch =  false
                
            }
        }
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        if state == .gameOver || state == .title{
        }
        else{
            if shouldmove{
                gridy += Int(moveSpeed)
                moveGrid()
            }
            if gridArray[0][0].position.y < -25{
                gridArray.remove(at: 0)
                gridAdd(1)
                gridy += Int(moveSpeed)
                score += 1
                scoreCount += 1
                if scoreCount % scoreLevel == 0 && score != 0 && moveSpeed < 14{
                    moveSpeed += 0.2
                    scrollSpeed += 3
                    scoreLevel += 2
                    scoreCount = 0
                }
                if score % 100 == 0 && score != 0 {
                    let woosh = SKAction.playSoundFileNamed("woosh.wav", waitForCompletion: false)
                    self.run(woosh)
                }
            }
            scrollWorld()
            
            let currentpos = self.circle.position
        
            for scanx in 0..<10{    //Colision indicator
                for scany in 0..<13 {
                    let scanpos = gridArray[scanx][scany].position
                    let calculateddistance = sqrt(pow(Double(scanpos.x - currentpos.x),2.0) + pow(Double(scanpos.y - currentpos.y),2.0))
                    if calculateddistance < 32.5 && gridArray[scanx][scany].exists{
                        gameOver()
                    }
                
                }
            }
        }
    }
    
    func gridAddBegin(){
        var leftCounter = 0
        var rightCounter = 13
        for row in  0 ..< 14{
            gridArray.append([])
            for gridX in 0..<14{
                let ypos = gridArray.count - 1
                if(gridX <= leftCounter || gridX  >= rightCounter){
                    addCreatureAtGrid(x:gridX, y:ypos, shown: true)
                }
                else{
                    addCreatureAtGrid(x:gridX, y:ypos, shown: false)
                }
            }
            if row % 2 == 0{
                if leftCounter < randmove {
                    leftCounter += 1
                }
                if rightCounter > randmove+6{
                    rightCounter -= 1
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
                 gridArray[gridX][gridY].position.y -= moveSpeed
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
             gridPosition = CGPoint(x: (Double)(x * side) + 12.5, y: Double(gridy +  y * side))      //the intialization
        }
        else{
             gridPosition = CGPoint(x: (Double)(x * side) + 12.5, y: Double(gridArray[gridArray.count-2][0].position.y) + 25)   //adding on to grid
        }

            
        square.position = gridPosition
        
        /* Add creature to grid node */
        addChild(square)
        
        /* Add creature to grid array */
        gridArray[gridArray.count - 1].append(square)
    }
    
    func scrollWorld() {
        /* Scroll World */
        scrollLayer.position.y -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through scroll layer nodes */
        for ground in scrollLayer.children as! [SKSpriteNode] {
            
            /* Get ground node position, convert node position to scene space */
            let groundPosition = scrollLayer.convert(ground.position, to: self)
            
            /* Check if ground sprite has left the scene */
            if groundPosition.y <= -ground.size.height / 2 + 5 {
                
                /* Reposition ground sprite to the second starting position */
                let newPosition = CGPoint(x: groundPosition.x, y: (self.size.height / 2) + ground.size.height)
                
                /* Convert new node position back to scroll layer space */
                ground.position = self.convert(newPosition, to: scrollLayer)
            }
        }
        
    }

    
    func gameOver(){
        let explode = SKAction(named: "Explode")!
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([explode,remove])
        self.circle.run(sequence)
        
        if backgroundMusic != nil {
            backgroundMusic.stop()
            backgroundMusic = nil
        }
        
        let explodeA = SKAction.playSoundFileNamed("explode.wav", waitForCompletion: false)
        self.run(explodeA)
        
        
        shouldmove = false
        if UserState.sharedInstance.highScore < score{
            UserState.sharedInstance.highScore = score
        }
        scoreLabel.fontSize = 25
        scoreLabel.text = "Score: " + String(score) + " High: " + String(UserState.sharedInstance.highScore)
        scoreBackground.isHidden = false
        gameOverLabel.isHidden = false
        restart.state = .msButtonNodeStateActive
        state = .gameOver
    }

    
    
}
