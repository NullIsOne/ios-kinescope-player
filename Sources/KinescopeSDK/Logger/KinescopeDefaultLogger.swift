public final class KinescopeDefaultLogger: KinescopeLogging {

    // MARK: - KinescopeLogging

    public func log(message: String, level: KinescopeLoggingLevel) {
        print("\(level): \(message)")
    }

    public func log(error: Error, level: KinescopeLoggingLevel) {
        print("\(level): \(error.localizedDescription)")
    }
}
