//
// Copyright (c) Vatsal Manot
//

import Swallow
import Swift

public protocol QueueProtocol {
    associatedtype Element
    
    mutating func enqueue(_: Element)
    mutating func dequeue() -> Element?
}
