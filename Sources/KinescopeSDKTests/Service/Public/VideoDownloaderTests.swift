//
//  VideoDownloaderTests.swift
//  KinescopeSDKTests
//
//  Created by Artemii Shabanov on 07.04.2021.
//

import XCTest
@testable import KinescopeSDK

final class VideoDownloaderTests: XCTestCase {

    // MARK: - Nested Types

    class MockDelegate: KinescopeDownloadableDelegate {
        var assets: [String: (progress: Double, completed: Bool, error: KinescopeDownloadError?)] = [:]

        func kinescopeDownloadProgress(assetId: String, progress: Double) {
            assets[assetId]?.progress = progress
        }

        func kinescopeDownloadError(assetId: String, error: KinescopeDownloadError) {
            assets[assetId]?.error = error
        }

        func kinescopeDownloadComplete(assetId: String) {
            assets[assetId]?.completed = true
        }
    }

    // MARK: - Setup

    var assetService: AssetServiceMock?
    var downloader: KinescopeDownloadable?
    var delegate: MockDelegate?

    override func setUp() {
        super.setUp()

        let mockAssetService = AssetServiceMock()
        self.downloader = VideoDownloader(videoPathsStorage: VideoPathsUDStorage(), assetService: mockAssetService)
        self.assetService = mockAssetService
        self.delegate = MockDelegate()
        self.downloader?.add(delegate: delegate!)
    }

    override func tearDown() {
        super.tearDown()

        downloader?.clear()
        downloader = nil
    }

    // MARK: - Tests

    func testDelegateConsistency() {

        // given

        delegate?.assets = [
            "id1": (progress: 0, completed: false, error: nil),
            "id2": (progress: 0, completed: false, error: nil),
            "id3": (progress: 0, completed: false, error: nil)
        ]
        assetService?.assetStates = [
            "id1": .progress(0.5),
            "id2": .error(KinescopeDownloadError.notFound),
            "id3": .completed("id3")
        ]

        // when

        for assetId in (assetService?.assetStates ?? [:]).keys {
            downloader?.enqueueDownload(assetId: assetId)
        }

        // then

        XCTAssertEqual(delegate?.assets["id1"]?.progress, 0.5)
        XCTAssertEqual(delegate?.assets["id2"]?.error, KinescopeDownloadError.notFound)
        XCTAssertEqual(delegate?.assets["id3"]?.completed, true)
    }

    func testPathConsistency() {

        // given

        assetService?.assetStates = [
            "id1": .completed("id1")
        ]

        // when

        downloader?.enqueueDownload(assetId: "id1")

        let baseURL = URL(fileURLWithPath: NSHomeDirectory())
        let assetURL = baseURL.appendingPathComponent("id1")
        let path = downloader?.getPath(by: "id1")

        // then

        XCTAssertEqual(path, assetURL)
    }

    func testClearConsistency() {

        // given

        assetService?.assetStates = [
            "id1": .completed("id1"),
            "id2": .completed("id2"),
            "id3": .completed("id3")
        ]

        // when

        for assetId in (assetService?.assetStates ?? [:]).keys {
            downloader?.enqueueDownload(assetId: assetId)
        }
        downloader?.clear()

        // then

        XCTAssertEqual(downloader?.downlaodedAssetsList(), [])
    }

    func testDeleteConsistency() {

        // given

        delegate?.assets = [
            "id1": (progress: 0, completed: false, error: nil)
        ]
        assetService?.assetStates = [
            "id1": .completed("id1")
        ]

        // when

        for assetId in (assetService?.assetStates ?? [:]).keys {
            downloader?.enqueueDownload(assetId: assetId)
        }

        // then

        XCTAssertEqual(delegate?.assets["id1"]?.completed, true)

        // when

        downloader?.delete(assetId: "id1")

        // then

        XCTAssertEqual(downloader?.getPath(by: "id1"), nil)
    }

    func testListConsistency() {

        // given

        assetService?.assetStates = [
            "id1": .completed("id1"),
            "id2": .completed("id2"),
            "id3": .progress(0.5),
            "id4": .completed("id4"),
            "id5": .progress(0.5),
            "id6": .progress(0.5)
        ]

        // when

        for assetId in (assetService?.assetStates ?? [:]).keys {
            downloader?.enqueueDownload(assetId: assetId)
        }

        // then

        XCTAssertEqual(Set(downloader?.downlaodedAssetsList() ?? []), Set(["id1", "id2", "id4"]))
    }

}

extension KinescopeDownloadError: Equatable {
    public static func == (lhs: KinescopeDownloadError, rhs: KinescopeDownloadError) -> Bool {
        switch (lhs, rhs) {
        case (.network, .network):
            return true
        case (.notFound, .notFound):
            return true
        case (.denied, .denied):
            return true
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }
}
