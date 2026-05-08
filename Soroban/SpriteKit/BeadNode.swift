import SpriteKit

class BeadNode: SKNode {
    var isHeaven: Bool = false
    var rodIndex: Int = 0
    var beadIndex: Int = 0
    private static let shadowColor = SKColor(red: 0.03, green: 0.02, blue: 0.01, alpha: 0.38)

    static func create(width: CGFloat, height: CGFloat, isHeaven: Bool, rodIndex: Int, beadIndex: Int) -> BeadNode {
        let node = BeadNode()
        node.isHeaven = isHeaven
        node.rodIndex = rodIndex
        node.beadIndex = beadIndex
        node.isUserInteractionEnabled = false

        // Cast shadow under each bead so it feels like it sits above the rods.
        let shadow = SKShapeNode(ellipseOf: CGSize(width: width * 0.86, height: height * 0.34))
        shadow.position = CGPoint(x: 0, y: -height * 0.14)
        shadow.fillColor = BeadNode.shadowColor
        shadow.strokeColor = .clear
        shadow.zPosition = -2
        node.addChild(shadow)

        // Bicone shape - traditional soroban bead
        let shape = SKShapeNode()
        let path = CGMutablePath()
        let hw = width / 2
        let hh = height / 2

        path.move(to: CGPoint(x: -hw, y: 0))
        path.addQuadCurve(to: CGPoint(x: 0, y: hh), control: CGPoint(x: -hw * 0.6, y: hh * 0.8))
        path.addQuadCurve(to: CGPoint(x: hw, y: 0), control: CGPoint(x: hw * 0.6, y: hh * 0.8))
        path.addQuadCurve(to: CGPoint(x: 0, y: -hh), control: CGPoint(x: hw * 0.6, y: -hh * 0.8))
        path.addQuadCurve(to: CGPoint(x: -hw, y: 0), control: CGPoint(x: -hw * 0.6, y: -hh * 0.8))
        path.closeSubpath()

        shape.path = path

        let baseColor = isHeaven
            ? SKColor(red: 0.17, green: 0.08, blue: 0.035, alpha: 1)
            : SKColor(red: 0.50, green: 0.27, blue: 0.105, alpha: 1)
        let edgeColor = isHeaven
            ? SKColor(red: 0.40, green: 0.22, blue: 0.11, alpha: 1)
            : SKColor(red: 0.72, green: 0.44, blue: 0.21, alpha: 1)

        shape.fillColor = baseColor
        shape.strokeColor = edgeColor
        shape.lineWidth = 1.4
        shape.zPosition = 0
        node.addChild(shape)

        // Top and bottom facets add depth to the bicone.
        let topFacet = SKShapeNode()
        let topPath = CGMutablePath()
        topPath.move(to: CGPoint(x: -hw * 0.88, y: 0))
        topPath.addQuadCurve(to: CGPoint(x: 0, y: hh * 0.92), control: CGPoint(x: -hw * 0.45, y: hh * 0.64))
        topPath.addQuadCurve(to: CGPoint(x: hw * 0.88, y: 0), control: CGPoint(x: hw * 0.45, y: hh * 0.64))
        topPath.addQuadCurve(to: CGPoint(x: -hw * 0.88, y: 0), control: CGPoint(x: 0, y: hh * 0.18))
        topPath.closeSubpath()
        topFacet.path = topPath
        topFacet.fillColor = SKColor(white: 1.0, alpha: isHeaven ? 0.06 : 0.10)
        topFacet.strokeColor = .clear
        topFacet.zPosition = 1
        node.addChild(topFacet)

        let lowerShade = SKShapeNode()
        let shadePath = CGMutablePath()
        shadePath.move(to: CGPoint(x: -hw * 0.9, y: -1))
        shadePath.addQuadCurve(to: CGPoint(x: 0, y: -hh * 0.94), control: CGPoint(x: -hw * 0.45, y: -hh * 0.62))
        shadePath.addQuadCurve(to: CGPoint(x: hw * 0.9, y: -1), control: CGPoint(x: hw * 0.45, y: -hh * 0.62))
        shadePath.addQuadCurve(to: CGPoint(x: -hw * 0.9, y: -1), control: CGPoint(x: 0, y: -hh * 0.12))
        shadePath.closeSubpath()
        lowerShade.path = shadePath
        lowerShade.fillColor = SKColor(white: 0.0, alpha: isHeaven ? 0.22 : 0.16)
        lowerShade.strokeColor = .clear
        lowerShade.zPosition = 1
        node.addChild(lowerShade)

        let gloss = SKShapeNode()
        let glossPath = CGMutablePath()
        let gw = width * 0.28
        let gh = height * 0.18
        glossPath.addEllipse(in: CGRect(x: -hw * 0.34, y: hh * 0.12, width: gw, height: gh))
        gloss.path = glossPath
        gloss.fillColor = SKColor(white: 1.0, alpha: 0.18)
        gloss.strokeColor = .clear
        gloss.zPosition = 1
        node.addChild(gloss)

        let grain = SKShapeNode()
        let grainPath = CGMutablePath()
        grainPath.move(to: CGPoint(x: -hw * 0.58, y: hh * 0.08))
        grainPath.addQuadCurve(to: CGPoint(x: hw * 0.52, y: hh * 0.02), control: CGPoint(x: 0, y: hh * 0.18))
        grainPath.move(to: CGPoint(x: -hw * 0.42, y: -hh * 0.14))
        grainPath.addQuadCurve(to: CGPoint(x: hw * 0.46, y: -hh * 0.10), control: CGPoint(x: 0, y: -hh * 0.22))
        grain.path = grainPath
        grain.strokeColor = SKColor(red: 0.95, green: 0.70, blue: 0.38, alpha: isHeaven ? 0.10 : 0.18)
        grain.lineWidth = 0.8
        grain.zPosition = 2
        node.addChild(grain)

        let hole = SKShapeNode(circleOfRadius: max(1.6, width * 0.045))
        hole.fillColor = SKColor(red: 0.08, green: 0.055, blue: 0.04, alpha: 0.72)
        hole.strokeColor = SKColor(white: 1.0, alpha: 0.12)
        hole.lineWidth = 0.5
        hole.zPosition = 3
        node.addChild(hole)

        return node
    }
}
