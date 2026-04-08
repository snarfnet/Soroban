import AVFoundation
import UIKit

class SoundManager {
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var clickBuffers: [AVAudioPCMBuffer] = []
    private var resetBuffer: AVAudioPCMBuffer?
    private let haptic = UIImpactFeedbackGenerator(style: .light)

    init() {
        setupEngine()
        generateSounds()
        haptic.prepare()
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
        let sampleRate: Double = 44100

        // Generate several click variations for realism
        for i in 0..<4 {
            if let buffer = generateWoodClick(
                sampleRate: sampleRate,
                duration: 0.035,
                pitchVariation: 1.0 + Double(i) * 0.08
            ) {
                clickBuffers.append(buffer)
            }
        }

        // Reset sound (multiple clicks in sequence)
        if let buffer = generateWoodClick(sampleRate: sampleRate, duration: 0.06, pitchVariation: 0.85) {
            resetBuffer = buffer
        }
    }

    private func generateWoodClick(sampleRate: Double, duration: Double, pitchVariation: Double) -> AVAudioPCMBuffer? {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount

        guard let data = buffer.floatChannelData?[0] else { return nil }

        let baseFreq = 2200.0 * pitchVariation
        let decayRate = 80.0

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let envelope = exp(-decayRate * t)

            // Wood-like sound: combination of frequencies with fast decay
            let tone1 = sin(2.0 * .pi * baseFreq * t) * 0.4
            let tone2 = sin(2.0 * .pi * baseFreq * 1.47 * t) * 0.25
            let tone3 = sin(2.0 * .pi * baseFreq * 2.09 * t) * 0.15

            // Add noise component for the "click" attack
            let noise = (Double.random(in: -1...1)) * max(0, 1.0 - t * 300) * 0.3

            let sample = Float((tone1 + tone2 + tone3 + noise) * envelope * 0.3)
            data[i] = sample
        }

        return buffer
    }

    func playBeadClick(velocity: CGFloat) {
        guard !clickBuffers.isEmpty, let player = playerNode else { return }

        let idx = Int.random(in: 0..<clickBuffers.count)
        let buffer = clickBuffers[idx]

        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)

        // Haptic feedback
        haptic.impactOccurred(intensity: min(velocity, 1.0))
    }

    func playResetSound() {
        guard let buffer = resetBuffer, let player = playerNode else { return }

        // Play multiple rapid clicks
        for i in 0..<3 {
            let delay = Double(i) * 0.04
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            }
        }

        haptic.impactOccurred(intensity: 0.8)
    }
}
