
public protocol PollStateProtocol {
    func isPending() -> Bool
    func hasFinished() -> Bool
    func hasStarted() -> Bool
}

public protocol Pollable: JSONParselable {
    var id: Int { get set }
    var state: PollStateProtocol { get set }
    var poll_to: String { get set }
}
