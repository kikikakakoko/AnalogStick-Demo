//
//  GameScene.swift
//
//  Created by Dmitriy Mitrophanskiy on 28.09.14.
//  Copyright (c) 2014 Dmitriy Mitrophanskiy. All rights reserved.
//
import SpriteKit


class GameScene: SKScene {
    var appleNode: SKSpriteNode?
    let jSizePlusSpriteNode = SKSpriteNode(imageNamed: "plus")
    let jSizeMinusSpriteNode = SKSpriteNode(imageNamed: "minus")
    let setJoystickStickImageBtn = SKLabelNode()
    let setJoystickSubstrateImageBtn = SKLabelNode()
    let joystickStickColorBtn = SKLabelNode(text: "Sticks random color")
    let joystickSubstrateColorBtn = SKLabelNode(text: "Substrates random color")
	
	let moveJoystick = 🕹(withDiameter: 100)
	let rotateJoystick = TLAnalogJoystick(withDiameter: 100)
    
    var airplain: SKSpriteNode?
    var joystickStickImageEnabled = true {
        didSet {
            let image = joystickStickImageEnabled ? UIImage(named: "jStick") : nil
            moveJoystick.handleImage = image
            rotateJoystick.handleImage = image
            setJoystickStickImageBtn.text = "\(joystickStickImageEnabled ? "Remove" : "Set") stick image"
        }
    }
    
    var joystickSubstrateImageEnabled = true {
        didSet {
            let image = joystickSubstrateImageEnabled ? UIImage(named: "jSubstrate") : nil
            moveJoystick.baseImage = image
            rotateJoystick.baseImage = image
            setJoystickSubstrateImageBtn.text = "\(joystickSubstrateImageEnabled ? "Remove" : "Set") substrate image"
        }
    }
    func makePlain() {
        let airplain = SKSpriteNode(imageNamed: "airplain")
        airplain.size = CGSize(width: 70, height: 70)
        airplain.position = CGPoint(x: frame.midX, y: frame.midY)
        airplain.zPosition = 5
        self.airplain = airplain
        addChild(self.airplain!)
    }
    
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        makePlain()
        backgroundColor = .white
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

		let moveJoystickHiddenArea = TLAnalogJoystickHiddenArea(rect: CGRect(x: 0, y: 0, width: frame.midX, height: frame.height))
		moveJoystickHiddenArea.joystick = moveJoystick
		moveJoystick.isMoveable = true
		addChild(moveJoystickHiddenArea)
		
		let rotateJoystickHiddenArea = TLAnalogJoystickHiddenArea(rect: CGRect(x: frame.midX, y: 0, width: frame.midX, height: frame.height))
		rotateJoystickHiddenArea.joystick = rotateJoystick
		addChild(rotateJoystickHiddenArea)
        
        //MARK: Handlers begin
		moveJoystick.on(.begin) { [unowned self] _ in
			let actions = [
				SKAction.scale(to: 0.5, duration: 0.5),
				SKAction.scale(to: 1, duration: 0.5)
			]

			self.appleNode?.run(SKAction.sequence(actions))
		}
		
		moveJoystick.on(.move) { [unowned self] joystick in
			guard let appleNode = self.appleNode else {
				return
			}
			
			let pVelocity = joystick.velocity;
			let speed = CGFloat(0.12)
            
			//appleNode.position = CGPoint(x: appleNode.position.x + (pVelocity.x * speed), y: appleNode.position.y + (pVelocity.y * speed))
            self.airplain!.position = CGPoint(x: self.airplain!.position.x + (pVelocity.x * speed), y: self.airplain!.position.y + (pVelocity.y * speed))
		}
        
		
		moveJoystick.on(.end) { [unowned self] _ in
			let actions = [
				SKAction.scale(to: 1.5, duration: 0.5),
				SKAction.scale(to: 1, duration: 0.5)
			]

			self.appleNode?.run(SKAction.sequence(actions))
		}
		
		rotateJoystick.on(.move) { [unowned self] joystick in
			guard let appleNode = self.appleNode else {
				return
			}

			appleNode.zRotation = joystick.angular
		}
		
		rotateJoystick.on(.end) { [unowned self] _ in
			self.appleNode?.run(SKAction.rotate(byAngle: 3.6, duration: 0.5))
		}
        
        //MARK: Handlers end
        let selfHeight = frame.height
        let btnsOffset: CGFloat = 10
        let btnsOffsetHalf = btnsOffset / 2
        let joystickSizeLabel = SKLabelNode(text: "Joysticks Size:")
        joystickSizeLabel.fontSize = 20
        joystickSizeLabel.fontColor = UIColor.black
        joystickSizeLabel.horizontalAlignmentMode = .left
        joystickSizeLabel.verticalAlignmentMode = .top
        joystickSizeLabel.position = CGPoint(x: btnsOffset, y: selfHeight - btnsOffset)
        addChild(joystickSizeLabel)
		
		let startLabelY = CGFloat(40)
        
		joystickStickImageEnabled = true
        joystickSubstrateImageEnabled = true

        addApple(CGPoint(x: frame.midX, y: frame.midY))

        view.isMultipleTouchEnabled = true
    }
    
    func addApple(_ position: CGPoint) {
        guard let appleImage = UIImage(named: "apple") else {
            return
        }
        
        let texture = SKTexture(image: appleImage)
        let apple = SKSpriteNode(texture: texture)
        apple.physicsBody = SKPhysicsBody(texture: texture, size: apple.size)
        apple.physicsBody!.affectedByGravity = false
        apple.position = position
        addChild(apple)
        appleNode = apple
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        if let touch = touches.first {
            let node = atPoint(touch.location(in: self))
            
            switch node {
            
            case setJoystickStickImageBtn:
                joystickStickImageEnabled = !joystickStickImageEnabled
            case setJoystickSubstrateImageBtn:
                joystickSubstrateImageEnabled = !joystickSubstrateImageEnabled
            case joystickStickColorBtn:
                setRandomStickColor()
            case joystickSubstrateColorBtn:
                setRandomSubstrateColor()
            default:
                addApple(touch.location(in: self))
            }
        }
    }
    
    func setRandomStickColor() {
        let randomColor = UIColor.random()
        moveJoystick.handleColor = randomColor
        rotateJoystick.handleColor = randomColor
    }
    
    func setRandomSubstrateColor() {
        let randomColor = UIColor.random()
        moveJoystick.baseColor = randomColor
        rotateJoystick.baseColor = randomColor
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1)
    }
}
