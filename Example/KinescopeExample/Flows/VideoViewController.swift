import UIKit
import KinescopeSDK

final class VideoViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var playerView: KinescopePlayerView!

    // MARK: - Private properties

    var videoId = ""
    private var player: KinescopeVideoPlayer?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        playerView.set(videoGravity: .resizeAspect)
        player = KinescopeVideoPlayer(videoId: videoId)
        player?.attach(view: playerView)
        player?.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.stop()
    }
}