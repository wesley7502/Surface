import SpriteKit

class Square: SKSpriteNode {
    
    /* Living neighbor counter */
    var neighborCount = 0
    
    var exists: Bool = false {
        didSet {
            /* Visibility */
            isHidden = !exists
        }
    }
    
    init() {
        /* Initialize with 'bubble' asset */
        let texture = SKTexture(imageNamed: "RedSquare")
        super.init(texture: texture, color: UIColor.clear, size: CGSize(width: 25, height: 25))
        
        /* Set Z-Position, ensure it's on top of grid */
        zPosition = 1
        
        /* Set anchor point to bottom-left */
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
