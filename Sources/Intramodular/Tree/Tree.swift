//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol Tree {
    associatedtype Children: Sequence where Children.Element: Tree
    associatedtype Value = Never where Child.Value == Value
    
    typealias Child = Children.Element
    
    var value: Value { get }
    var children: Children { get }
}

public protocol MutableTree: Tree where Children: MutableSequence {
    var value: Value { get set }
    var children: Children { get set }
}

public protocol ConstructibleTree: Tree, Identifiable {
    init(value: Value, children: Children)
}

public protocol RecursiveTree: Tree where Child == Self {
    
}

public protocol ParentPointerTree: RecursiveTree {
    var parent: Self? { get }
}

// MARK: - Implementation -

extension Tree where Value == Never {
    public var value: Never {
        fatalError()
    }
}

extension MutableTree where Value == Never {
    public var value: Never {
        get {
            fatalError()
        } set {
            
        }
    }
}

// MARK: - Type-erasure -

public struct AnyTreeNode<Value>: Tree {
    public let value: Value
    public let children: AnySequence<AnyTreeNode<Value>>
    
    public init(value: Value, children: AnySequence<AnyTreeNode<Value>>) {
        self.value = value
        self.children = children
    }
}

public struct AnyIdentifiableTreeNode<ID: Hashable, Value>: Identifiable, Tree {
    public let id: ID
    public let value: Value
    public let children: AnySequence<AnyTreeNode<Value>>
    
    public init(id: ID, value: Value, children: AnySequence<AnyTreeNode<Value>>) {
        self.id = id
        self.value = value
        self.children = children
    }
}
