import AVFoundation

public class KinescopeVideoPlayer: KinescopePlayer {

    // MARK: - Private Properties

    private let dependencies: KinescopePlayerDependencies
    private lazy var strategy: PlayingStrategy = {
        dependencies.provide(for: config)
    }()

    private weak var view: KinescopePlayerView?
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?

    private var video: KinescopeVideo?
    private let config: KinescopePlayerConfig

    // MARK: - Lifecycle

    init(config: KinescopePlayerConfig, dependencies: KinescopePlayerDependencies) {
        self.dependencies = dependencies
        self.config = config
    }

    // MARK: - KinescopePlayer

    public required convenience init(config: KinescopePlayerConfig) {
        self.init(config: config, dependencies: KinescopeVideoPlayerDependencies())
    }

    public func play() {
        if video != nil {
            self.strategy.play()
        } else {
            self.load()
        }
    }

    public func pause() {
        self.strategy.pause()
    }

    public func stop() {
        self.strategy.pause()
        self.strategy.unbind()
    }

    public func attach(view: KinescopePlayerView) {

        view.playerView.player = self.strategy.player
        view.delegate = self

        self.view = view

        observePlaybackTime()
        addPlayerStatusObserver()
    }

    public func detach(view: KinescopePlayerView) {
        view.playerView.player = nil
        self.view = nil
        view.delegate = nil

        removePlaybackTimeObserver()
        removePlayerStatusObserver()
    }

    public func select(quality: KinescopeVideoQuality) {
        guard let item = quality.item else {
            // Log here critical error
            return
        }

        // Restore here sek position

        strategy.bind(item: item)
    }

}

// MARK: - Private

private extension KinescopeVideoPlayer {

    /// Sends request video by id and sets player's item
    func load() {
        view?.startLoader()

        dependencies.inspector.video(
            id: config.videoId,
            onSuccess: { [weak self] video in
                self?.video = video
                self?.select(quality: .auto(hlsLink: video.hlsLink))
                self?.view?.overlay?.set(title: video.title, subtitle: video.description)
                self?.play()
            },
            onError: { [weak self] error in
                self?.view?.stopLoader()
                debugPrint(error)
            }
        )
    }

    func observePlaybackTime() {

        guard view?.controlPanel != nil else {
            return
        }

        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let period = CMTimeMakeWithSeconds(0.1, preferredTimescale: timeScale)

        timeObserver = strategy.player.addPeriodicTimeObserver(forInterval: period,
                                                               queue: .main) { [weak self] time in
            let time = time.seconds
            self?.view?.controlPanel?.setIndicator(to: time)
            Kinescope.shared.logger?.log(message: "current time \(time)", level: KinescopeLoggerLevel.player)
        }

    }

    func removePlaybackTimeObserver() {
        if let timeObserver = timeObserver {
            strategy.player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }

    func addPlayerStatusObserver() {
        self.statusObserver = self.strategy.player.observe(
            \.status,
            options: [.new, .old],
            changeHandler: { [weak self] item, _ in
                self?.view?.change(status: item.status)
            }
        )
    }

    func removePlayerStatusObserver() {
        self.statusObserver?.invalidate()
        self.statusObserver = nil
    }
}

// MARK: - PlayerOverlayViewDelegate

extension KinescopeVideoPlayer: KinescopePlayerViewDelegate {
    func didPlay(videoEnded: Bool) {
        if videoEnded {
            self.strategy.player.seek(to: .zero)
        }

        self.play()
    }

    func didPause() {
        self.pause()
    }

    func didSelect(option: KinescopePlayerOption) {
    }
}
