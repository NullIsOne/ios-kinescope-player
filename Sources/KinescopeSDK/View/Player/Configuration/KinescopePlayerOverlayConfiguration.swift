//
//  KinescopePlayerOverlayConfiguration.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 30.03.2021.
//

import UIKit

/// Appearence preferences for overlay above video
public struct KinescopePlayerOverlayConfiguration {
    
    let playImage: UIImage
    let pauseImage: UIImage
    let fastForwardImage: UIImage
    let fastBackwardImage: UIImage
    let playBackgroundRadius: CGFloat
    let playBackgroundColor: UIColor
    let backgroundColor: UIColor
    let duration: TimeInterval
    let nameConfiguration: KinescopeVideoNameConfiguration
    
    /// - parameter playImage: Image showing If video started after tapping on overlay
    /// - parameter pauseImage: Image showing If video paused after tapping on overlay
    /// - parameter fastForwardImage: Image for icon of fast forward action
    /// - parameter fastBackwardImage: Image for icon of fast backward action
    /// - parameter playBackgroundRadius: Radius of circle used to highlight play button at overlay
    /// - parameter playBackgroundColor: Background color of play button at center of overlay
    /// - parameter backgroundColor: Background color of overlay
    /// - parameter duration: Duration of overlay appear animation in seconds
    /// - parameter nameConfiguration: Appearence preferences for title and subtitle above video
    public init(playImage: UIImage,
                pauseImage: UIImage,
                fastForwardImage: UIImage,
                fastBackwardImage: UIImage,
                playBackgroundRadius: CGFloat,
                playBackgroundColor: UIColor,
                backgroundColor: UIColor,
                duration: TimeInterval,
                nameConfiguration: KinescopeVideoNameConfiguration) {
        self.playImage = playImage
        self.pauseImage = pauseImage
        self.fastForwardImage = fastForwardImage
        self.fastBackwardImage = fastBackwardImage
        self.playBackgroundRadius = playBackgroundRadius
        self.playBackgroundColor = playBackgroundColor
        self.backgroundColor = backgroundColor
        self.duration = duration
        self.nameConfiguration = nameConfiguration
    }
}

// MARK: - Defaults

public extension KinescopePlayerOverlayConfiguration {
    
    static func builder() -> KinescopePlayerOverlayConfigurationBuilder {
        .init(configuration: .default)
    }

    static let `default`: KinescopePlayerOverlayConfiguration = .init(
        playImage: UIImage.image(named: "play"),
        pauseImage: UIImage.image(named: "pause"),
        fastForwardImage: UIImage.image(named: "fastForward"),
        fastBackwardImage: UIImage.image(named: "fastBackward"),
        playBackgroundRadius: 48,
        playBackgroundColor: UIColor(red: 0.38, green: 0.38, blue: 0.988, alpha: 1),
        backgroundColor: UIColor.black.withAlphaComponent(0.3),
        duration: 5.0,
        nameConfiguration: .default
    )
    
}

// MARK: - Builder

public class KinescopePlayerOverlayConfigurationBuilder {
    
    private var playImage: UIImage
    private var pauseImage: UIImage
    private var fastForwardImage: UIImage
    private var fastBackwardImage: UIImage
    private var playBackgroundRadius: CGFloat
    private var playBackgroundColor: UIColor
    private var backgroundColor: UIColor
    private var duration: TimeInterval
    private var nameConfiguration: KinescopeVideoNameConfiguration
    
    public init(configuration: KinescopePlayerOverlayConfiguration) {
        self.playImage = configuration.playImage
        self.pauseImage = configuration.pauseImage
        self.fastForwardImage = configuration.fastForwardImage
        self.fastBackwardImage = configuration.fastBackwardImage
        self.playBackgroundRadius = configuration.playBackgroundRadius
        self.playBackgroundColor = configuration.playBackgroundColor
        self.backgroundColor = configuration.backgroundColor
        self.duration = configuration.duration
        self.nameConfiguration = configuration.nameConfiguration
    }
    
    public func setPlayImage(_ image: UIImage) -> Self {
        playImage = image
        return self
    }
    
    public func setPauseImage(_ image: UIImage) -> Self {
        pauseImage = image
        return self
    }
    
    public func setFastForwardImage(_ image: UIImage) -> Self {
        fastForwardImage = image
        return self
    }
    
    public func setFastBackwardImage(_ image: UIImage) -> Self {
        fastBackwardImage = image
        return self
    }
    
    public func setPlayBackgroundRadius(_ radius: CGFloat) -> Self {
        playBackgroundRadius = radius
        return self
    }

    public func setPlayBackgroundColor(_ color: UIColor) -> Self {
        playBackgroundColor = color
        return self
    }

    public func setBackgroundColor(_ color: UIColor) -> Self {
        backgroundColor = color
        return self
    }
    
    public func setDuration(_ duration: TimeInterval) -> Self {
        self.duration = duration
        return self
    }
    
    public func setNameConfiguration(_ configuration: KinescopeVideoNameConfiguration) -> Self {
        nameConfiguration = configuration
        return self
    }
    
    public func build() -> KinescopePlayerOverlayConfiguration {
        return .init(playImage: playImage,
                     pauseImage: pauseImage,
                     fastForwardImage: fastForwardImage,
                     fastBackwardImage: fastBackwardImage,
                     playBackgroundRadius: playBackgroundRadius,
                     playBackgroundColor: playBackgroundColor,
                     backgroundColor: backgroundColor,
                     duration: duration,
                     nameConfiguration: nameConfiguration)
    }
    
}
