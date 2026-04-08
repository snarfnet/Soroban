import SpriteKit
import CoreMotion

class SorobanScene: SKScene {

    // MARK: - Configuration
    private let rodCount = 13
    private let heavenBeadsPerRod = 1
    private let earthBeadsPerRod = 4

    // MARK: - State
    weak var sorobanState: SorobanState?
    private var rods: [SorobanRod] = []
    private var motionManager = CMMotionManager()
    private var soundManager = SoundManager()
    private var draggedBead: BeadNode?
    private var dragStartY: CGFloat = 0
    private var gravityY: CGFloat = -1.0

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
        startMotionUpdates()
        observeNotifications()
    }

    override func willMove(from view: SKView) {
        motionManager.stopDeviceMotionUpdates()
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
        let frameColor = SKColor(red: 0.35, green: 0.20, blue: 0.10, alpha: 1)
        let beamColor = SKColor(red: 0.40, green: 0.24, blue: 0.12, alpha: 1)
        let frameThickness: CGFloat = 10
        let beamThickness: CGFloat = 8

        // Outer frame
        let outerFrame = SKShapeNode(rect: frameRect, cornerRadius: 6)
        outerFrame.strokeColor = frameColor
        outerFrame.lineWidth = frameThickness
        outerFrame.fillColor = .clear
        outerFrame.zPosition = 5
        addChild(outerFrame)

        // Inner wood fill
        let woodBg = SKShapeNode(rect: frameRect.insetBy(dx: frameThickness / 2, dy: frameThickness / 2), cornerRadius: 3)
        woodBg.fillColor = SKColor(red: 0.25, green: 0.15, blue: 0.08, alpha: 1)
        woodBg.strokeColor = .clear
        woodBg.zPosition = 0
        addChild(woodBg)

        // Beam (reckoning bar)
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

        // Dot markers on beam (traditional: at rods for units marking)
        let dotPositions = [3, 6, 9] // 0-indexed, every 3rd for traditional
        for pos in dotPositions {
            if pos < rodCount {
                let dotX = rodStartX + CGFloat(pos) * rodSpacing
                let dot = SKShapeNode(circleOfRadius: 3)
                dot.position = CGPoint(x: dotX, y: beamY)
                dot.fillColor = SKColor(red: 0.9, green: 0.85, blue: 0.7, alpha: 1)
                dot.strokeColor = .clear
                dot.zPosition = 11
                addChild(dot)
            }
        }

        // Rods (vertical lines)
        let rodColor = SKColor(red: 0.55, green: 0.50, blue: 0.45, alpha: 1)
        for i in 0..<rodCount {
            let x = rodStartX + CGFloat(i) * rodSpacing
            let rod = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: bottomFrameY + 5))
            path.addLine(to: CGPoint(x: x, y: topFrameY - 5))
            rod.path = path
            rod.strokeColor = rodColor
            rod.lineWidth = 2
            rod.zPosition = 1
            addChild(rod)
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
            // Move earth beads - move this bead and all above/below it
            let beadIdx = bead.beadIndex
            let targetActive = deltaY > beadHeight * 0.3
            let targetInactive = deltaY < -beadHeight * 0.3
            if targetActive {
                // Activate this bead and all below it (closer to frame)
                for j in stride(from: beadIdx, through: 0, by: -1) {
                    if !rod.earthActive[j] {
                        moveEarthBead(rod: rod, index: j, active: true)
                    }
                }
            } else if targetInactive {
                // Deactivate this bead and all above it (closer to beam)
                for j in beadIdx..<earthBeadsPerRod {
                    if rod.earthActive[j] {
                        moveEarthBead(rod: rod, index: j, active: false)
                    }
                }
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
                    if rod.earthActive[beadIdx] {
                        // Deactivate this and all above
                        for j in beadIdx..<earthBeadsPerRod {
                            if rod.earthActive[j] {
                                moveEarthBead(rod: rod, index: j, active: false)
                            }
                        }
                    } else {
                        // Activate this and all below
                        for j in stride(from: beadIdx, through: 0, by: -1) {
                            if !rod.earthActive[j] {
                                moveEarthBead(rod: rod, index: j, active: true)
                            }
                        }
                    }
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
        soundManager.playBeadClick(velocity: 0.7)
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
        soundManager.playBeadClick(velocity: 0.5)
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

    // MARK: - Motion (Gyroscope Gravity)

    private func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self = self, let motion = motion else { return }
            // In landscape, gravity.x maps to the "vertical" axis of the soroban
            // gravity.y maps to horizontal tilt
            let gy = motion.gravity.y
            // For landscape orientation, gy maps to vertical effect on beads
            self.gravityY = -gy
            self.applyGravity()
        }
    }

    private func applyGravity() {
        // When device is tilted significantly, unset beads may slide
        // Threshold for "strong tilt" that would move beads
        let threshold = 0.6

        if abs(gravityY) > threshold {
            let tiltDown = gravityY < -threshold // beads should fall down (away from beam for heaven, toward frame for earth)

            for rod in rods {
                if tiltDown {
                    // Strong downward tilt - heaven beads deactivate, earth beads deactivate
                    if rod.heavenActive[0] {
                        moveHeavenBead(rod: rod, active: false)
                    }
                    for j in 0..<earthBeadsPerRod {
                        if rod.earthActive[j] {
                            moveEarthBead(rod: rod, index: j, active: false)
                        }
                    }
                } else {
                    // Strong upward tilt - heaven beads activate, earth beads activate
                    if !rod.heavenActive[0] {
                        moveHeavenBead(rod: rod, active: true)
                    }
                    for j in 0..<earthBeadsPerRod {
                        if !rod.earthActive[j] {
                            moveEarthBead(rod: rod, index: j, active: true)
                        }
                    }
                }
            }
        }
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
