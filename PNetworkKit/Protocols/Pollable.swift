
public protocol PollStatusProtocol {
    func isPending() -> Bool
    func hasFinished() -> Bool
    func hasStarted() -> Bool
}

public protocol Pollable: JSONParselable {
    var id: Int { get set }
    var state: PollStatusProtocol { get set }
    var poll_to: String { get set }
}
