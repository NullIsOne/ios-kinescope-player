//
//  Manager+KinescopeConfigurable.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

import Foundation

// MARK: - KinescopeConfigurable

extension Manager: KinescopeConfigurable {

    func setConfig(_ config: KinescopeConfig) {
        self.config = config
        self.assetDownloader = AssetDownloader(fileService: FileNetworkService(downloadIdentifier: "assets"),
                                               assetLinksService: AssetLinksNetworkService(transport: Transport(), config: config))
        self.attachmentDownloader = AttachmentDownloader(fileService: FileNetworkService(downloadIdentifier: "attachments"))
        self.videoDownloader = VideoDownloader(videoPathsStorage: VideoPathsUDStorage(),
                                               assetService: AssetNetworkService())
        self.inspector = Inspector(videosService: VideosNetworkService(transport: Transport(),
                                                                       config: config))

        self.eventsCenter = LocalEventsCenter(analitycsService: ())
    }

    func set(logger: KinescopeLogging, levels: [KinescopeLoggingLevel]) {
        self.logger = KinescopeLogger(logger: logger, levels: levels)
    }

}
