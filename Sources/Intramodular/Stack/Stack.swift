//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol Stack: Poppable where PeekResult == Element, PopResult == Element {
    associatedtype Element
    associatedtype PushResult
    
    mutating func push(_: Element) -> PushResult
}

// MARK: - Concrete Implementations -

public struct ArrayStack<T>: ImplementationForwardingMutableStore, ExpressibleByArrayLiteral, Initiable, Stack {
    public typealias Storage = [T]
    
    public typealias ArrayLiteralElement = Storage.ArrayLiteralElement
    public typealias Element = Storage.Element
    
    public var storage: Storage
    
    public init(storage: Storage) {
        self.storage = storage
    }
    
    public mutating func push(_ element: Element) {
        storage.append(element)
    }
    
    public mutating func pop() -> Element {
        return storage.removeLast()
    }
    
    public func peek() -> Element {
        return storage[.last]
    }
}
