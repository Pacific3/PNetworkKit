
public enum PollState: String {
    case Pending = "pending"
    case Finished = "finished"
}

public protocol Pollable: JSONParselable {
    var id: Int { get set }
    var state: PollState { get set }
    var poll_to: String { get set }
}