//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A tree-like data structure.
public protocol RecursiveTreeProtocol<Value>: TreeProtocol where Children.Element: RecursiveTreeProtocol<Value>, Children.Element.Value == Value {
    /// The value stored in the current node.
    var value: Value { get }
    /// The children of the current node.
    var children: Children { get }
}

/// A mutable tree.
public protocol MutableRecursiveTree: RecursiveTreeProtocol where Children: MutableSequence {
    var value: Value { get set }
    var children: Children { get set }
}

public protocol HomogeneousRecursiveTree: RecursiveTreeProtocol where Children.Element == Self {
    
}

extension HomogeneousRecursiveTree {
    public func recursiveFirst(
        where predicate: (Value) -> Bool
    ) -> Self? {
        if predicate(value) {
            return self
        }
        
        for child in children {
            if let found = child.recursiveFirst(where: { predicate($0) }) {
                return found
            }
        }
        
        return nil
    }
}
