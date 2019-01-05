//
//  AKDynamicRangeCompressorAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AVFoundation

public class AKDynamicRangeCompressorAudioUnit: AKAudioUnitBase {

    func setParameter(_ address: AKDynamicRangeCompressorParameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AKDynamicRangeCompressorParameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var ratio: Double = AKDynamicRangeCompressor.defaultRatio {
        didSet { setParameter(.ratio, value: ratio) }
    }

    var threshold: Double = AKDynamicRangeCompressor.defaultThreshold {
        didSet { setParameter(.threshold, value: threshold) }
    }

    var attackDuration: Double = AKDynamicRangeCompressor.defaultAttackDuration {
        didSet { setParameter(.attackDuration, value: attackDuration) }
    }

    var releaseDuration: Double = AKDynamicRangeCompressor.defaultReleaseDuration {
        didSet { setParameter(.releaseDuration, value: releaseDuration) }
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createDynamicRangeCompressorDSP(Int32(count), sampleRate)
    }

    public override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)
        let ratio = AUParameterTree.createParameter(
            identifier: "ratio",
            name: "Ratio to compress with, a value > 1 will compress",
            address: AKDynamicRangeCompressorParameter.ratio.rawValue,
            min: Float(AKDynamicRangeCompressor.ratioRange.lowerBound),
            max: Float(AKDynamicRangeCompressor.ratioRange.upperBound),
            unit: .hertz,
            flags: .default)
        let threshold = AUParameterTree.createParameter(
            identifier: "threshold",
            name: "Threshold (in dB) 0 = max",
            address: AKDynamicRangeCompressorParameter.threshold.rawValue,
            min: Float(AKDynamicRangeCompressor.thresholdRange.lowerBound),
            max: Float(AKDynamicRangeCompressor.thresholdRange.upperBound),
            unit: .generic,
            flags: .default)
        let attackDuration = AUParameterTree.createParameter(
            identifier: "attackDuration",
            name: "Attack duration",
            address: AKDynamicRangeCompressorParameter.attackDuration.rawValue,
            min: Float(AKDynamicRangeCompressor.attackDurationRange.lowerBound),
            max: Float(AKDynamicRangeCompressor.attackDurationRange.upperBound),
            unit: .seconds,
            flags: .default)
        let releaseDuration = AUParameterTree.createParameter(
            identifier: "releaseDuration",
            name: "Release duration",
            address: 3,
            min: Float(AKDynamicRangeCompressor.releaseDurationRange.lowerBound),
            max: Float(AKDynamicRangeCompressor.releaseDurationRange.upperBound),
            unit: .seconds,
            flags: .default)

        setParameterTree(AUParameterTree.createTree(withChildren: [ratio, threshold, attackDuration, releaseDuration]))
        ratio.value = Float(AKDynamicRangeCompressor.defaultRatio)
        threshold.value = Float(AKDynamicRangeCompressor.defaultThreshold)
        attackDuration.value = Float(AKDynamicRangeCompressor.defaultAttackDuration)
        releaseDuration.value = Float(AKDynamicRangeCompressor.defaultReleaseDuration)
    }

    public override var canProcessInPlace: Bool { return true }

}
