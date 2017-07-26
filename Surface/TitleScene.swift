//
//  TitleScene.swift
//  Surface
//
//  Created by Tsai Family on 6/15/17.
//  Copyright © 2017 MakeSchool. All rights reserved.
//

import SpriteKit
import AVFoundation
import GameKit

class TitleScene: SKScene {
    
    /* UI Connections */
    var titleMusic: AVAudioPlayer!
    
    var canActivate = false
    
    var timer: Double = 0.0      //The timer that manageDistance

    
    override func didMove(to view: SKView) {
        
        self.view?.showsFPS = false
        self.view?.showsNodeCount = false
        self.view?.showsDrawCount = false
        self.view?.showsFields = false
        
            
            let path = Bundle.main.path(forResource: "Sweltering Spheres.mp3", ofType:nil)!
            let url = URL(fileURLWithPath: path)
            
            do {
                let sound = try AVAudioPlayer(contentsOf: url)
                self.titleMusic = sound
                sound.numberOfLoops = -1
                sound.play()
            } catch {
                // couldn't load file :(
            }

    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if timer == 0.0{
            timer = currentTime
        }
        if currentTime - timer >= 4.0{
                canActivate =  true
        }

        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if(canActivate){
            
            if self.titleMusic != nil {
                self.titleMusic.stop()
                self.titleMusic = nil
            }
        
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene?.scaleMode = .aspectFit
            
            /* Show debug */
            skView?.showsDrawCount = true
            skView?.showsFPS = true
            
            /* Start game scene */
            skView?.presentScene(scene)
        }
        
        
    }
    
}
