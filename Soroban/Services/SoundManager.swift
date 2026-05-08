import AVFoundation
import UIKit

class SoundManager {
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var clickBuffers: [AVAudioPCMBuffer] = []
    private var softClickBuffers: [AVAudioPCMBuffer] = []
    private var resetBuffer: AVAudioPCMBuffer?
    private let haptic = UIImpactFeedbackGenerator(style: .rigid)
    private let softHaptic = UIImpactFeedbackGenerator(style: .light)

    init() {
        setupEngine()
        generateSounds()
        haptic.prepare()
        softHaptic.prepare()
    }

    private func setupEngine() {
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
            player.play()
        } catch {
            print("Audio engine error: \(error)")
        }

        self.audioEngine = engine
        self.playerNode = player
    }

    private func generateSounds() {
        let sr: Double = 44100

        // Generate 6 wood click variations (bead hitting beam - sharp attack)
        for i in 0..<6 {
            let pitch = 1.0 + Double(i) * 0.05 - 0.125
            if let buf = generateWoodImpact(sampleRate: sr, duration: 0.025, pitch: pitch, intensity: 1.0) {
                clickBuffers.append(buf)
            }
        }

        // Generate softer clicks (bead hitting bead)
        for i in 0..<4 {
            let pitch = 0.9 + Double(i) * 0.06
            if let buf = generateWoodImpact(sampleRate: sr, duration: 0.018, pitch: pitch, intensity: 0.5) {
                softClickBuffers.append(buf)
            }
        }

        // Reset: a quick "zara" sliding sound
        resetBuffer = generateSlideSound(sampleRate: sr, duration: 0.12)
    }

    /// Realistic wood-on-wood impact sound
    /// Uses filtered noise burst + resonant body modes
    private func generateWoodImpact(sampleRate: Double, duration: Double, pitch: Double, intensity: Double) -> AVAudioPCMBuffer? {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        guard let data = buffer.floatChannelData?[0] else { return nil }

        // Wood resonant frequencies (soroban bead is small hardwood)
        let f1 = 3200.0 * pitch   // Primary resonance
        let f2 = 4800.0 * pitch   // Second partial
        let f3 = 6400.0 * pitch   // Third partial
        let f4 = 1800.0 * pitch   // Body resonance (lower)

        // State for simple one-pole lowpass filter on noise
        var noiseState: Double = 0.0
        let noiseCutoff = 0.15  // Lower = darker noise

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate

            // Attack envelope: extremely fast rise, fast decay
            // Real wood impact peaks in < 0.5ms
            let attackTime = 0.0004
            let attack = min(t / attackTime, 1.0)
            let decay1 = exp(-180.0 * t)  // Very fast initial decay
            let decay2 = exp(-60.0 * t)   // Slower body resonance decay
            let envelope = attack * (decay1 * 0.7 + decay2 * 0.3)

            // Noise burst (the "crack" of impact)
            let rawNoise = Double.random(in: -1...1)
            noiseState += noiseCutoff * (rawNoise - noiseState)
            let noiseBurst = noiseState * exp(-350.0 * t) * 0.6

            // Resonant modes (wood body vibrations)
            let mode1 = sin(2.0 * .pi * f1 * t) * 0.25 * decay1
            let mode2 = sin(2.0 * .pi * f2 * t) * 0.15 * decay1
            let mode3 = sin(2.0 * .pi * f3 * t) * 0.08 * decay1
            let mode4 = sin(2.0 * .pi * f4 * t) * 0.20 * decay2  // Body thump

            // Combine
            let sample = (noiseBurst + mode1 + mode2 + mode3 + mode4) * envelope * intensity * 0.45

            // Soft clipping for warmth
            let clipped = tanh(sample * 1.5) / 1.5
            data[i] = Float(clipped)
        }

        return buffer
    }

    /// Sliding sound for reset (multiple beads sliding at once)
    private func generateSlideSound(sampleRate: Double, duration: Double) -> AVAudioPCMBuffer? {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        guard let data = buffer.floatChannelData?[0] else { return nil }

        var noiseState: Double = 0.0

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let progress = t / duration

            // Envelope: crescendo then quick decay (beads sliding then hitting frame)
            let env: Double
            if progress < 0.7 {
                env = progress / 0.7 * 0.4
            } else {
                env = 0.4 + (1.0 - (progress - 0.7) / 0.3) * 0.6
            }

            // Filtered noise (wooden sliding friction)
            let rawNoise = Double.random(in: -1...1)
            let cutoff = 0.08 + progress * 0.12
            noiseState += cutoff * (rawNoise - noiseState)

            // Add some rattling (rapid micro-impacts)
            let rattle = sin(2.0 * .pi * (2500.0 + progress * 500.0) * t) * Double.random(in: 0...0.3)

            let sample = (noiseState * 0.5 + rattle * 0.3) * env * 0.35

            // Impact at the end
            let endImpact = progress > 0.85 ? exp(-200.0 * (t - duration * 0.85)) * 0.5 : 0.0
            let impactNoise = Double.random(in: -1...1) * endImpact

            data[i] = Float(tanh((sample + impactNoise) * 1.5) / 1.5)
        }

        return buffer
    }

    func playBeadClick(velocity: CGFloat) {
        guard let player = playerNode else { return }

        let buffers = velocity > 0.5 ? clickBuffers : softClickBuffers
        guard !buffers.isEmpty else { return }

        let idx = Int.random(in: 0..<buffers.count)
        player.scheduleBuffer(buffers[idx], at: nil, options: [], completionHandler: nil)

        if velocity > 0.5 {
            haptic.impactOccurred(intensity: min(velocity, 1.0))
        } else {
            softHaptic.impactOccurred(intensity: velocity)
        }
    }

    func playBeadStackClick(intensity: CGFloat) {
        guard let player = playerNode else { return }

        let primaryBuffers = clickBuffers.isEmpty ? softClickBuffers : clickBuffers
        guard !primaryBuffers.isEmpty else { return }

        let primaryIndex = Int.random(in: 0..<primaryBuffers.count)
        player.scheduleBuffer(primaryBuffers[primaryIndex], at: nil, options: [], completionHandler: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.018) { [weak self] in
            guard let self = self else { return }
            let secondaryBuffers = self.softClickBuffers.isEmpty ? primaryBuffers : self.softClickBuffers
            guard !secondaryBuffers.isEmpty else { return }

            let secondaryIndex = Int.random(in: 0..<secondaryBuffers.count)
            player.scheduleBuffer(secondaryBuffers[secondaryIndex], at: nil, options: [], completionHandler: nil)
        }

        haptic.impactOccurred(intensity: min(max(intensity, 0.35), 1.0))
    }

    func playResetSound() {
        guard let buffer = resetBuffer, let player = playerNode else { return }
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)

        // Follow with a sharp click (beads hitting the frame)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) { [weak self] in
            guard let self = self, !self.clickBuffers.isEmpty else { return }
            let idx = Int.random(in: 0..<self.clickBuffers.count)
            player.scheduleBuffer(self.clickBuffers[idx], at: nil, options: [], completionHandler: nil)
        }

        haptic.impactOccurred(intensity: 0.9)
    }
}
