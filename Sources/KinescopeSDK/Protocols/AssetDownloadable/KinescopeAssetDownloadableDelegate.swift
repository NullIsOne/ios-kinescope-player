//
//  KinescopeAssetDownloadableDelegate.swift
//  KinescopeSDK
//
//  Created by Никита Коробейников on 23.03.2021.
//

import Foundation

/// Delegate protocol to listen assets download process events
public protocol KinescopeAssetDownloadableDelegate: AnyObject {

    /// Notify about progress state of downloading task
    ///
    /// - parameter assetId: Asset id of concrete video quality
    /// - parameter progress: Progress of process
    func assetDownloadProgress(assetId: String, progress: Double)

    /// Notify about error state of downloading task
    ///
    /// - parameter assetId: Asset id of concrete video quality
    /// - parameter error: Reason of failure
    func assetDownloadError(assetId: String, error: KinescopeDownloadError)

    /// Notify about successfully completed downloading task
    ///
    /// - parameter assetId: Asset id of concrete video quality
    /// - parameter url: URL path to cache of saved asset file, nil if attachment didn't saved
    func assetDownloadComplete(assetId: String, url: URL?)

}
