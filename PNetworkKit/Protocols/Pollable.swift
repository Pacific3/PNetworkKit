
public protocol PollState {
    func isPending() -> Bool
    func isFinished() -> Bool
}

public protocol Pollable: JSONParselable {
    var id: Int { get set }
    var state: PollState { get set }
    var poll_to: String { get set }
}