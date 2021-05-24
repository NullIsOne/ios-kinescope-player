//
//  FileService.swift
//  KinescopeSDK
//
//  Created by Никита Гагаринов on 09.04.2021.
//

import Foundation

/// FileService delegate
protocol FileServiceDelegate: AnyObject {
    /// Trigerred on progress change
    /// - Parameters:
    ///   - fileId: file id
    ///   - progress: download progress
    func downloadProgress(fileId: String, progress: Double)
    /// Triggered on donwlod error
    /// - Parameters:
    ///   - fileId: file id
    ///   - error: download error
    func downloadError(fileId: String, error: KinescopeDownloadError)
    /// Triggered on donwlod success
    /// - Parameters:
    ///   - fileId: file id
    ///   - location: path to downloaded file
    func downloadComplete(fileId: String, location: URL)
}

/// Service managing files downloading
protocol FileService {
    /// Delegate
    var delegate: FileServiceDelegate? { get set }
    /// Starts download
    /// - Parameters:
    ///   - fileId: file id
    ///   - url: url to file
    func enqueueDownload(fileId: String, url: URL)
    /// Pauses download
    /// - Parameter fileId: file id
    func pauseDownload(fileId: String)
    /// Continues download if it was paused before
    /// - Parameter fileId: file id
    func resumeDownload(fileId: String)
    /// Stops download
    /// - Parameter fileId: file id
    func dequeueDownload(fileId: String)
    /// Restores downloding session if it was interrupted before
    func restore()
}

/// FileService implementation
final class FileNetworkService: NSObject, FileService {

    // MARK: - Constants

    private enum Constants {
        static let downloadIdentifierPrefix = "io.kinescope.file_download_session."
    }

    // MARK: - Properties

    weak var delegate: FileServiceDelegate?
    private let idsStorage: IDsStorage
    // Should be unique and consistent across app launches
    private let downloadIdentifier: String
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: Constants.downloadIdentifierPrefix + downloadIdentifier)
        let urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        return urlSession
    }()

    // MARK: - Initialization

    init(downloadIdentifier: String, idsStorage: IDsStorage = IDsUDStorage()) {
        self.downloadIdentifier = downloadIdentifier
        self.idsStorage = idsStorage
    }

    // MARK: - Internal Methods

    func setSession(_ session: URLSession) {
        self.session = session
    }

    // MARK: - FileService

    func enqueueDownload(fileId: String, url: URL) {
        findTask(of: fileId) { task in
            task.resume()
        } notFoundCompletion: { [weak self] in
            self?.idsStorage.save(id: fileId, by: url.absoluteString)
            let task = self?.session.downloadTask(with: url)
            task?.resume()
        }
    }

    func dequeueDownload(fileId: String) {
        findTask(of: fileId) { [weak self] task in
            self?.idsStorage.deleteID(by: task.currentRequest?.url?.absoluteString ?? "")
            task.cancel()
        } notFoundCompletion: { [weak self] in
            self?.delegate?.downloadError(fileId: fileId, error: .notFound)
        }
    }

    func pauseDownload(fileId: String) {
        findTask(of: fileId) { task in
            task.suspend()
        } notFoundCompletion: { [weak self] in
            self?.delegate?.downloadError(fileId: fileId, error: .notFound)
        }
    }

    func resumeDownload(fileId: String) {
        findTask(of: fileId) { task in
            task.resume()
        } notFoundCompletion: { [weak self] in
            self?.delegate?.downloadError(fileId: fileId, error: .notFound)
        }
    }

    func restore() {
        session.getAllTasks { [weak self] tasksArray in
            // For each task, restore the state in the app
            for task in tasksArray {
                guard
                    let downloadTask = task as? URLSessionDownloadTask,
                    let url = downloadTask.currentRequest?.url?.absoluteString
                else {
                    continue
                }
                if self?.idsStorage.contains(url: url) ?? false {
                    downloadTask.resume()
                }
            }
        }
    }

}

// MARK: - URLSessionDownloadDelegate

extension FileNetworkService: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard
            let taskUrl = downloadTask.currentRequest?.url?.absoluteString,
            let fileId = idsStorage.deleteID(by: taskUrl)
        else {
            return
        }
        delegate?.downloadComplete(fileId: fileId, location: location)
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard
            let taskUrl = downloadTask.currentRequest?.url?.absoluteString,
            let fileId = idsStorage.readID(by: taskUrl)
        else {
            return
        }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        delegate?.downloadProgress(fileId: fileId, progress: progress)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard
            let taskUrl = task.currentRequest?.url?.absoluteString,
            let id = idsStorage.deleteID(by: taskUrl),
            let error = error
        else {
            return
        }
        delegate?.downloadError(fileId: id, error: .unknown(error))
    }

}

// MARK: - Private Methods

private extension FileNetworkService {

    func getId(for task: URLSessionDownloadTask) -> String? {
        guard let taskUrl = task.currentRequest?.url?.absoluteString else {
            return nil
        }
        return idsStorage.readID(by: taskUrl)
    }

    func findTask(of fileId: String, completion: @escaping (URLSessionDownloadTask) -> Void, notFoundCompletion: @escaping () -> Void) {
        session.getAllTasks { [weak self] tasks in
            for task in tasks {
                guard
                    let downloadTask = task as? URLSessionDownloadTask,
                    let taskUrl = downloadTask.currentRequest?.url?.absoluteString,
                    let id = self?.idsStorage.readID(by: taskUrl),
                    fileId == id
                else {
                    continue
                }
                completion(downloadTask)
                return
            }
            notFoundCompletion()
        }
    }

}
