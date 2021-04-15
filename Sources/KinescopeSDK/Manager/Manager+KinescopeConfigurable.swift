//
//  Manager+KinescopeConfigurable.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

import AVFoundation

// MARK: - KinescopeConfigurable

extension Manager: KinescopeConfigurable {

    func setupSesson() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch(let error) {
            self.logger?.log(error: error, level: KinescopeLoggerLevel.player)
        }
    }

    func setConfig(_ config: KinescopeConfig) {
        self.config = config
        self.downloader = VideoDownloader(apiKey: config.apiKey)
        self.inspector = Inspector(videosService: VideosNetworkService(transport: Transport(),
                                                                       config: config))
    }

    func set(logger: KinescopeLogging, levels: [KinescopeLoggingLevel]) {
        self.logger = KinescopeLogger(logger: logger, levels: levels)
    }

}
