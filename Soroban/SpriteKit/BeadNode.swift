import SpriteKit

class BeadNode: SKNode {
    var isHeaven: Bool = false
    var rodIndex: Int = 0
    var beadIndex: Int = 0

    static func create(width: CGFloat, height: CGFloat, isHeaven: Bool, rodIndex: Int, beadIndex: Int) -> BeadNode {
        let node = BeadNode()
        node.isHeaven = isHeaven
        node.rodIndex = rodIndex
        node.beadIndex = beadIndex
        node.isUserInteractionEnabled = false

        // Bicone (diamond) shape - traditional soroban bead
        let shape = SKShapeNode()
        let path = CGMutablePath()
        let hw = width / 2
        let hh = height / 2

        // Diamond/bicone shape
        path.move(to: CGPoint(x: -hw, y: 0))
        path.addQuadCurve(to: CGPoint(x: 0, y: hh), control: CGPoint(x: -hw * 0.6, y: hh * 0.8))
        path.addQuadCurve(to: CGPoint(x: hw, y: 0), control: CGPoint(x: hw * 0.6, y: hh * 0.8))
        path.addQuadCurve(to: CGPoint(x: 0, y: -hh), control: CGPoint(x: hw * 0.6, y: -hh * 0.8))
        path.addQuadCurve(to: CGPoint(x: -hw, y: 0), control: CGPoint(x: -hw * 0.6, y: -hh * 0.8))
        path.closeSubpath()

        shape.path = path

        if isHeaven {
            shape.fillColor = SKColor(red: 0.20, green: 0.12, blue: 0.06, alpha: 1)
            shape.strokeColor = SKColor(red: 0.30, green: 0.18, blue: 0.10, alpha: 1)
        } else {
            shape.fillColor = SKColor(red: 0.45, green: 0.28, blue: 0.14, alpha: 1)
            shape.strokeColor = SKColor(red: 0.55, green: 0.35, blue: 0.18, alpha: 1)
        }
        shape.lineWidth = 1
        shape.zPosition = 0
        node.addChild(shape)

        // Highlight/gloss effect
        let gloss = SKShapeNode()
        let glossPath = CGMutablePath()
        let gw = width * 0.35
        let gh = height * 0.25
        glossPath.addEllipse(in: CGRect(x: -gw / 2, y: hh * 0.05, width: gw, height: gh))
        gloss.path = glossPath
        gloss.fillColor = SKColor(white: 1.0, alpha: 0.12)
        gloss.strokeColor = .clear
        gloss.zPosition = 1
        node.addChild(gloss)

        // Rod hole (center dot)
        let hole = SKShapeNode(circleOfRadius: 1.5)
        hole.fillColor = SKColor(red: 0.4, green: 0.38, blue: 0.35, alpha: 0.6)
        hole.strokeColor = .clear
        hole.zPosition = 2
        node.addChild(hole)

        return node
    }
}
