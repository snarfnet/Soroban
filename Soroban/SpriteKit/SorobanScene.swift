import SpriteKit

class SorobanScene: SKScene {

    // MARK: - Configuration
    private let rodCount = 13
    private let heavenBeadsPerRod = 1
    private let earthBeadsPerRod = 4

    // MARK: - State
    weak var sorobanState: SorobanState?
    private var rods: [SorobanRod] = []
    private var soundManager = SoundManager()
    private var draggedBead: BeadNode?
    private var dragStartY: CGFloat = 0

    // MARK: - Layout constants (calculated in didMove)
    private var frameRect = CGRect.zero
    private var beamY: CGFloat = 0
    private var rodSpacing: CGFloat = 0
    private var rodStartX: CGFloat = 0
    private var beadWidth: CGFloat = 0
    private var beadHeight: CGFloat = 0
    private var topFrameY: CGFloat = 0
    private var bottomFrameY: CGFloat = 0
    private var heavenTopY: CGFloat = 0
    private var earthBottomY: CGFloat = 0
    private var beadSpacing: CGFloat = 2

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.12, green: 0.10, blue: 0.08, alpha: 1)
        calculateLayout()
        buildFrame()
        buildRods()
        observeNotifications()
    }

    override func willMove(from view: SKView) {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Layout

    private func calculateLayout() {
        let margin: CGFloat = 20
        let sorobanWidth = size.width - margin * 2
        let sorobanHeight = size.height * 0.85

        let sorobanY = (size.height - sorobanHeight) / 2

        frameRect = CGRect(
            x: margin,
            y: sorobanY,
            width: sorobanWidth,
            height: sorobanHeight
        )

        // Beam divides at ~30% from top (heaven is smaller)
        let beamRatio: CGFloat = 0.30
        beamY = frameRect.minY + sorobanHeight * (1 - beamRatio)
        topFrameY = frameRect.maxY
        bottomFrameY = frameRect.minY

        rodSpacing = sorobanWidth / CGFloat(rodCount + 1)
        rodStartX = frameRect.minX + rodSpacing

        beadWidth = rodSpacing * 0.82
        beadHeight = min(sorobanHeight * 0.065, beadWidth * 0.6)
        beadSpacing = beadHeight * 0.15

        heavenTopY = topFrameY - beadHeight * 0.8
        earthBottomY = bottomFrameY + beadHeight * 0.8
    }

    // MARK: - Build Soroban Frame

    private func buildFrame() {
        let frameColor = SKColor(red: 0.30, green: 0.16, blue: 0.07, alpha: 1)
        let beamColor = SKColor(red: 0.38, green: 0.20, blue: 0.09, alpha: 1)
        let frameThickness: CGFloat = 12
        let beamThickness: CGFloat = 10

        let tableShadow = SKShapeNode(rect: frameRect.offsetBy(dx: 0, dy: -5), cornerRadius: 10)
        tableShadow.fillColor = SKColor(red: 0.02, green: 0.015, blue: 0.01, alpha: 0.55)
        tableShadow.strokeColor = .clear
        tableShadow.zPosition = -2
        addChild(tableShadow)

        let woodBg = SKShapeNode(rect: frameRect.insetBy(dx: frameThickness / 2, dy: frameThickness / 2), cornerRadius: 6)
        woodBg.fillColor = SKColor(red: 0.20, green: 0.105, blue: 0.045, alpha: 1)
        woodBg.strokeColor = .clear
        woodBg.zPosition = 0
        addChild(woodBg)

        addWoodGrain(in: frameRect.insetBy(dx: frameThickness, dy: frameThickness), zPosition: 0.5)

        let outerFrame = SKShapeNode(rect: frameRect, cornerRadius: 6)
        outerFrame.strokeColor = frameColor
        outerFrame.lineWidth = frameThickness
        outerFrame.fillColor = .clear
        outerFrame.zPosition = 5
        addChild(outerFrame)

        let innerHighlight = SKShapeNode(rect: frameRect.insetBy(dx: frameThickness * 0.55, dy: frameThickness * 0.55), cornerRadius: 5)
        innerHighlight.strokeColor = SKColor(red: 0.72, green: 0.48, blue: 0.24, alpha: 0.35)
        innerHighlight.lineWidth = 1
        innerHighlight.fillColor = .clear
        innerHighlight.zPosition = 6
        addChild(innerHighlight)

        let beamRect = CGRect(
            x: frameRect.minX,
            y: beamY - beamThickness / 2,
            width: frameRect.width,
            height: beamThickness
        )
        let beam = SKShapeNode(rect: beamRect)
        beam.fillColor = beamColor
        beam.strokeColor = SKColor(red: 0.45, green: 0.28, blue: 0.15, alpha: 1)
        beam.lineWidth = 1
        beam.zPosition = 10
        addChild(beam)

        let beamHighlight = SKShapeNode(rect: CGRect(
            x: beamRect.minX + 4,
            y: beamRect.maxY - 2,
            width: beamRect.width - 8,
            height: 1
        ))
        beamHighlight.fillColor = SKColor(red: 0.82, green: 0.55, blue: 0.28, alpha: 0.42)
        beamHighlight.strokeColor = .clear
        beamHighlight.zPosition = 11
        addChild(beamHighlight)

        let dotPositions = [3, 6, 9] // 0-indexed, every 3rd for traditional
        for pos in dotPositions {
            if pos < rodCount {
                let dotX = rodStartX + CGFloat(pos) * rodSpacing
                let dot = SKShapeNode(circleOfRadius: 3.6)
                dot.position = CGPoint(x: dotX, y: beamY)
                dot.fillColor = SKColor(red: 0.92, green: 0.78, blue: 0.42, alpha: 1)
                dot.strokeColor = SKColor(red: 0.35, green: 0.20, blue: 0.09, alpha: 0.55)
                dot.lineWidth = 0.8
                dot.zPosition = 12
                addChild(dot)
            }
        }

        let rodColor = SKColor(red: 0.68, green: 0.62, blue: 0.53, alpha: 1)
        for i in 0..<rodCount {
            let x = rodStartX + CGFloat(i) * rodSpacing
            let rodShadow = SKShapeNode()
            let shadowPath = CGMutablePath()
            shadowPath.move(to: CGPoint(x: x + 1.4, y: bottomFrameY + 7))
            shadowPath.addLine(to: CGPoint(x: x + 1.4, y: topFrameY - 7))
            rodShadow.path = shadowPath
            rodShadow.strokeColor = SKColor(red: 0.02, green: 0.015, blue: 0.01, alpha: 0.45)
            rodShadow.lineWidth = 2.6
            rodShadow.zPosition = 1
            addChild(rodShadow)

            let rod = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: bottomFrameY + 7))
            path.addLine(to: CGPoint(x: x, y: topFrameY - 7))
            rod.path = path
            rod.strokeColor = rodColor
            rod.lineWidth = 2.2
            rod.zPosition = 1
            addChild(rod)

            let rodGlint = SKShapeNode()
            let glintPath = CGMutablePath()
            glintPath.move(to: CGPoint(x: x - 0.6, y: bottomFrameY + 10))
            glintPath.addLine(to: CGPoint(x: x - 0.6, y: topFrameY - 10))
            rodGlint.path = glintPath
            rodGlint.strokeColor = SKColor(white: 1.0, alpha: 0.20)
            rodGlint.lineWidth = 0.7
            rodGlint.zPosition = 2
            addChild(rodGlint)
        }
    }

    private func addWoodGrain(in rect: CGRect, zPosition: CGFloat) {
        let grainColors = [
            SKColor(red: 0.58, green: 0.33, blue: 0.13, alpha: 0.20),
            SKColor(red: 0.10, green: 0.055, blue: 0.025, alpha: 0.26),
            SKColor(red: 0.82, green: 0.56, blue: 0.28, alpha: 0.12)
        ]

        let lineCount = 22
        for i in 0..<lineCount {
            let y = rect.minY + rect.height * CGFloat(i + 1) / CGFloat(lineCount + 1)
            let path = CGMutablePath()
            path.move(to: CGPoint(x: rect.minX + 8, y: y))

            let control1 = CGPoint(x: rect.midX * 0.72, y: y + CGFloat((i % 5) - 2) * 1.6)
            let control2 = CGPoint(x: rect.midX * 1.28, y: y + CGFloat((i % 7) - 3) * 1.3)
            path.addCurve(
                to: CGPoint(x: rect.maxX - 8, y: y + CGFloat((i % 3) - 1)),
                control1: control1,
                control2: control2
            )

            let grain = SKShapeNode()
            grain.path = path
            grain.strokeColor = grainColors[i % grainColors.count]
            grain.lineWidth = i % 4 == 0 ? 1.1 : 0.7
            grain.zPosition = zPosition
            addChild(grain)
        }
    }

    // MARK: - Build Rods and Beads

    private func buildRods() {
        rods = []
        for i in 0..<rodCount {
            let x = rodStartX + CGFloat(i) * rodSpacing
            let rod = SorobanRod(
                index: i,
                x: x,
                beamY: beamY,
                topY: heavenTopY,
                bottomY: earthBottomY,
                beadWidth: beadWidth,
                beadHeight: beadHeight,
                beadSpacing: beadSpacing
            )
            rods.append(rod)

            // Create heaven bead
            let heavenBead = BeadNode.create(
                width: beadWidth,
                height: beadHeight,
                isHeaven: true,
                rodIndex: i,
                beadIndex: 0
            )
            heavenBead.position = rod.heavenRestPosition(active: false)
            heavenBead.zPosition = 20
            addChild(heavenBead)
            rod.heavenBeads.append(heavenBead)

            // Create earth beads
            for j in 0..<earthBeadsPerRod {
                let earthBead = BeadNode.create(
                    width: beadWidth,
                    height: beadHeight,
                    isHeaven: false,
                    rodIndex: i,
                    beadIndex: j
                )
                earthBead.position = rod.earthRestPosition(index: j, active: false)
                earthBead.zPosition = 20
                addChild(earthBead)
                rod.earthBeads.append(earthBead)
            }
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Find bead at touch location
        let tappedNodes = nodes(at: location)
        for node in tappedNodes {
            if let bead = node as? BeadNode ?? node.parent as? BeadNode {
                draggedBead = bead
                dragStartY = location.y
                return
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let bead = draggedBead else { return }
        let location = touch.location(in: self)
        let deltaY = location.y - dragStartY

        let rodIdx = bead.rodIndex
        guard rodIdx < rods.count else { return }
        let rod = rods[rodIdx]

        if bead.isHeaven {
            // Move heaven bead
            let targetActive = deltaY < -beadHeight * 0.3
            let targetInactive = deltaY > beadHeight * 0.3
            if targetActive && !rod.heavenActive[0] {
                moveHeavenBead(rod: rod, active: true)
            } else if targetInactive && rod.heavenActive[0] {
                moveHeavenBead(rod: rod, active: false)
            }
        } else {
            let beadIdx = bead.beadIndex
            let targetActive = deltaY > beadHeight * 0.3
            let targetInactive = deltaY < -beadHeight * 0.3
            if targetActive && !rod.earthActive[beadIdx] {
                moveEarthBead(rod: rod, index: beadIdx, active: true)
                dragStartY = location.y
            } else if targetInactive && rod.earthActive[beadIdx] {
                moveEarthBead(rod: rod, index: beadIdx, active: false)
                dragStartY = location.y
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let bead = draggedBead {
            guard let touch = touches.first else {
                draggedBead = nil
                return
            }
            let location = touch.location(in: self)
            let deltaY = abs(location.y - dragStartY)

            // If barely moved, treat as tap (toggle)
            if deltaY < beadHeight * 0.3 {
                let rodIdx = bead.rodIndex
                guard rodIdx < rods.count else { draggedBead = nil; return }
                let rod = rods[rodIdx]

                if bead.isHeaven {
                    moveHeavenBead(rod: rod, active: !rod.heavenActive[0])
                } else {
                    let beadIdx = bead.beadIndex
                    moveEarthBead(rod: rod, index: beadIdx, active: !rod.earthActive[beadIdx])
                }
            }
        }
        draggedBead = nil
    }

    // MARK: - Bead Movement

    private func moveHeavenBead(rod: SorobanRod, active: Bool) {
        guard rod.heavenActive[0] != active else { return }
        rod.heavenActive[0] = active
        let bead = rod.heavenBeads[0]
        let target = rod.heavenRestPosition(active: active)
        let move = SKAction.move(to: target, duration: 0.08)
        move.timingMode = .easeOut
        bead.run(move)
        soundManager.playBeadStackClick(intensity: 0.75)
        updateValue()
    }

    private func moveEarthBead(rod: SorobanRod, index: Int, active: Bool) {
        guard rod.earthActive[index] != active else { return }
        rod.earthActive[index] = active
        let bead = rod.earthBeads[index]
        let target = rod.earthRestPosition(index: index, active: active)
        let move = SKAction.move(to: target, duration: 0.06)
        move.timingMode = .easeOut
        bead.run(move)
        soundManager.playBeadStackClick(intensity: 0.55)
        updateValue()
    }

    // MARK: - Value Calculation

    private func updateValue() {
        var totalValue: Int64 = 0
        for (i, rod) in rods.enumerated() {
            let placeValue = pow(10.0, Double(rodCount - 1 - i))
            var rodValue = 0
            if rod.heavenActive[0] { rodValue += 5 }
            for j in 0..<earthBeadsPerRod {
                if rod.earthActive[j] { rodValue += 1 }
            }
            totalValue += Int64(Double(rodValue) * placeValue)
        }

        let formatted = formatNumber(totalValue)

        DispatchQueue.main.async { [weak self] in
            self?.sorobanState?.displayValue = formatted
        }
    }

    private func formatNumber(_ value: Int64) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    // MARK: - Reset

    private func resetSoroban() {
        for rod in rods {
            if rod.heavenActive[0] {
                moveHeavenBead(rod: rod, active: false)
            }
            for j in 0..<earthBeadsPerRod {
                if rod.earthActive[j] {
                    moveEarthBead(rod: rod, index: j, active: false)
                }
            }
        }
        soundManager.playResetSound()
    }

    private func observeNotifications() {
        NotificationCenter.default.addObserver(
            forName: .sorobanReset,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.resetSoroban()
        }
    }
}
