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

public protocol RecursiveHomogenousTree: RecursiveTreeProtocol where Children.Element == Self {
    
}

extension RecursiveHomogenousTree {
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

extension RecursiveTreeProtocol {
    public func map<T>(_ transform: (Value) -> T) -> ArrayTree<T> {
        let mappedValue = transform(value)
        let mappedChildren = children.map({ $0.map(transform) })
        
        return ArrayTree(value: mappedValue, children: mappedChildren)
    }
    
    public func compactMap<T>(_ transform: (Value) -> T?) -> ArrayTree<T>? {
        guard let mappedValue = transform(value) else {
            return nil
        }
        
        let mappedChildren = children.compactMap({ $0.compactMap(transform) })
        
        return ArrayTree(value: mappedValue, children: mappedChildren)
    }
}
