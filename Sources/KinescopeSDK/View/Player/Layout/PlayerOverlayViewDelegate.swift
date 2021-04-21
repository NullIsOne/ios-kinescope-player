protocol PlayerOverlayViewDelegate: class {
    func didTap(isSelected: Bool)
    func didPlay()
    func didPause()
    func didFastForward()
    func didFastBackward()
}
