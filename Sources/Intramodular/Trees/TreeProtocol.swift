//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A tree-like data structure.
public protocol TreeProtocol {
    /// The type of sequence that represents the children of a node in the tree.
    associatedtype Children: Sequence where Children.Element: TreeProtocol
    /// The type of value stored in each node of the tree.
    associatedtype TreeValue
    
    /// The value stored in the current node.
    var value: TreeValue { get }
    /// The children of the current node.
    var children: Children { get }
}

/// A tree that can be constructed from a value and a list of children.
public protocol ConstructibleTree: RecursiveTreeProtocol {
    init(value: TreeValue, children: Children)
}

/// A tree with a pointer to its parent.
public protocol ReferenceParentPointerTree: AnyObject, RecursiveHomogenousTree {
    var parent: Self? { get }
}

// MARK: - Extensions

extension TreeProtocol where Self: ConstructibleTree & RecursiveHomogenousTree, Children: RangeReplaceableCollection {
    public init<T: RecursiveTreeProtocol>(
        from tree: T
    ) where T.TreeValue == TreeValue {
        self.init(value: tree.value, children: Children(tree.children.lazy.map({ Self(from: $0) })))
    }
    
    public init(value: TreeValue, children: some Collection<Self>) {
        self.init(value: value, children: .init(children))
    }
}

// MARK: - Type-erasure

public struct AnyTreeNode<Value>: RecursiveTreeProtocol {
    public let value: Value
    public let children: AnySequence<AnyTreeNode<Value>>
    
    public init(value: Value, children: AnySequence<AnyTreeNode<Value>>) {
        self.value = value
        self.children = children
    }
}

extension RecursiveTreeProtocol {
    public func eraseToAnyTreeNode() -> AnyTreeNode<TreeValue> {
        .init(value: value, children: .init(children.lazy.map({ $0.eraseToAnyTreeNode() })))
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
