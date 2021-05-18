//
//  KinescopeVideoPlayerTests.swift
//  KinescopeSDKTests
//
//  Created by Никита Коробейников on 29.03.2021.
//

import XCTest
@testable import KinescopeSDK

final class KinescopeVideoPlayerTests: XCTestCase {

    private enum Constants {
        static let hlsStub = "https://example.com/playlist.m3u8"
        static let videoId = "123"
        static let videoStub: KinescopeVideo = .stub(id: videoId, hlsLink: hlsStub)
    }

    var player: KinescopeVideoPlayer?
    var inspector: KinescopeInspectableMock?
    var downloader: KinescopeAssetDownloadableMock?
    var attachmentDownloader: KinescopeAttachmentDownloaderMock?
    var strategy: PlayingStrategyMock?

    override func setUp() {
        super.setUp()

        let inspector = KinescopeInspectableMock()
        let downloader = KinescopeAssetDownloadableMock()
        let strategy = PlayingStrategyMock()
        let attachmentDownloader = KinescopeAttachmentDownloaderMock()

        let dependencies = KinescopeVideoPlayerDependenciesMock(inspectorMock: inspector,
                                                                assetDownloaderMock: downloader,
                                                                strategyMock: strategy,
                                                                attachmentDownloaderMock: attachmentDownloader,
                                                                eventsCenter: LocalEventsCenter())

        self.player = KinescopeVideoPlayer(config: .init(videoId: Constants.videoId),
                                           dependencies: dependencies)

        self.inspector = inspector
        self.strategy = strategy
        self.attachmentDownloader = attachmentDownloader
    }

    override func tearDown() {
        super.tearDown()

        inspector = nil
        strategy = nil
    }

    func testPlayInitiateLoadingAndDelegateToStrategy() {

        // given

        inspector?.videoSuccessMock[Constants.videoId] = Constants.videoStub

        // when

        player?.play()

        // then

        XCTAssertEqual(inspector?.videoRequests.count, 1)
        XCTAssertEqual(strategy?.bindItems.count, 1)
        XCTAssertEqual(strategy?.playCalledCount, 1)
        XCTAssertEqual(strategy?.pauseCalledCount, 0)
        XCTAssertEqual(strategy?.unbindCalledCount, 0)

    }

    func testPauseDelegateToStrategy() {

        // when

        player?.pause()

        // then

        XCTAssertEqual(strategy?.bindItems.count, 0)
        XCTAssertEqual(strategy?.playCalledCount, 0)
        XCTAssertEqual(strategy?.pauseCalledCount, 1)
        XCTAssertEqual(strategy?.unbindCalledCount, 0)
    }

    func testStopDelegateToStrategy() {

        // when

        player?.stop()

        // then

        XCTAssertEqual(strategy?.bindItems.count, 0)
        XCTAssertEqual(strategy?.playCalledCount, 0)
        XCTAssertEqual(strategy?.pauseCalledCount, 1)
        XCTAssertEqual(strategy?.unbindCalledCount, 1)

    }

    func testSelectQualityDelegateToStrategy() {
        // given

        let quality: KinescopeVideoQuality = KinescopeStreamVideoQuality(hlsLink: Constants.hlsStub,
                                                                         audioLocale: nil,
                                                                         subtitlesLocale: nil,
                                                                         isAuto: true)

        // when

        player?.select(quality: quality)

        // then

        XCTAssertEqual(strategy?.bindItems.count, 1)
        XCTAssertEqual(strategy?.playCalledCount, 0)
        XCTAssertEqual(strategy?.pauseCalledCount, 0)
        XCTAssertEqual(strategy?.unbindCalledCount, 0)
    }
}
