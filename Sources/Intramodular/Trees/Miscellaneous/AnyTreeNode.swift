//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct AnyTreeNode<Value>: HomogenousTree {
    public let value: Value
    public let children: AnySequence<AnyTreeNode<Value>>
    
    public init(value: Value, children: AnySequence<AnyTreeNode<Value>>) {
        self.value = value
        self.children = children
    }
}

public struct AnyIdentifiableTreeNode<ID: Hashable, Value>: Identifiable, RecursiveTreeProtocol {
    public let id: ID
    public let value: Value
    public let children: AnySequence<AnyTreeNode<Value>>
    
    public init(id: ID, value: Value, children: AnySequence<AnyTreeNode<Value>>) {
        self.id = id
        self.value = value
        self.children = children
    }
}

extension RecursiveTreeProtocol {
    public func eraseToAnyTreeNode() -> AnyTreeNode<TreeValue> {
        .init(
            value: value,
            children: .init(children.lazy.map({ $0.eraseToAnyTreeNode() }))
        )
    }
}
