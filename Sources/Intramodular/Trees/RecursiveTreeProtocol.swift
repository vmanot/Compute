//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A tree-like data structure.
public protocol RecursiveTreeProtocol<TreeValue>: TreeProtocol where Children.Element: RecursiveTreeProtocol<TreeValue>, Children.Element.TreeValue == TreeValue {
    /// The value stored in the current node.
    var value: TreeValue { get }
    /// The children of the current node.
    var children: Children { get }
}

/// A mutable tree.
public protocol MutableRecursiveTree: RecursiveTreeProtocol where Children: MutableSequence {
    var value: TreeValue { get set }
    var children: Children { get set }
}

extension RecursiveTreeProtocol {
    public func mapValues<T>(
        _ transform: (TreeValue) -> T
    ) -> ArrayTree<T> {
        let mappedValue = transform(value)
        let mappedChildren = children.map({ $0.mapValues(transform) })
        
        return ArrayTree(value: mappedValue, children: mappedChildren)
    }
    
    public func compactMapValues<T>(
        _ transform: (TreeValue) -> T?
    ) -> ArrayTree<T>? {
        guard let mappedValue = transform(value) else {
            return nil
        }
        
        let mappedChildren = children.compactMap({ $0.compactMapValues(transform) })
        
        return ArrayTree(value: mappedValue, children: mappedChildren)
    }
}

extension HomogenousTree {
    public func first(
        where predicate: (Self) throws -> Bool
    ) rethrows -> Self? {
        if try predicate(self) {
            return self
        } else {
            for child in children {
                if try predicate(child) {
                    return child
                } else if let result = try child.first(where: predicate) {
                    return result
                }
            }
            
            return nil
        }
    }
    
    public func map<T>(
        _ transform: (Self) throws -> T
    ) rethrows -> ArrayTree<T> {
        return ArrayTree(
            value: try transform(self),
            children: try children.map({ try $0.map(transform) })
        )
    }
    
    public func compactMap<T>(
        _ transform: (Self) throws -> T?
    ) rethrows -> ArrayTree<T>? {
        guard let mapped = try transform(self) else {
            return nil
        }
            
        return ArrayTree(
            value: mapped,
            children: try children.compactMap({ try $0.compactMap(transform) })
        )
    }
    
    public func reduce<T>(
        initial: T,
        _ combine: (T, TreeValue, [T]) -> T
    ) -> T {
        let reduced = children.map({ $0.reduce(initial: initial, combine) })
        
        return combine(initial, value, reduced)
    }
}

public struct _IdentifiedTreeNodeParentRelationshipsDump<Node, ID: Hashable> {
    public let nodesByID: [ID: Node]
    public let relationships: [(id: ID, parentID: ID?)]
    
    public subscript(id: ID) -> Node {
        nodesByID[id]!
    }
}

extension ConstructibleTree where Self: HomogenousTree, Children: RangeReplaceableCollection {
    public init?<Element, ID: Hashable>(
        from elements: [Element],
        id: KeyPath<Element, ID>,
        parent: KeyPath<Element, ID?>,
        value: KeyPath<Element, TreeValue>
    ) throws {
        guard let (rootElementIndex, rootElement) = try elements.lazy
            .enumerated()
            .filter({ $0.element[keyPath: parent] == nil })
            .toCollectionOfZeroOrOne()?
            .value
        else {
            return nil
        }
        
        self.init(
            value: rootElement[keyPath: value],
            children: try Self._makeChildren(
                from: elements.removing(at: rootElementIndex),
                parentID: rootElement[keyPath: id],
                id: id,
                parent: parent,
                value: value
            )
        )
    }
    
    private static func _makeChildren<Element, ID: Hashable>(
        from elements: [Element],
        parentID: ID,
        id: KeyPath<Element, ID>,
        parent: KeyPath<Element, ID?>,
        value: KeyPath<Element, TreeValue>
    ) throws -> Children {
        let directChildren = elements.enumerated().filter {
            $0.element[keyPath: parent] == parentID
        }
        
        guard !directChildren.isEmpty else {
            guard elements.isEmpty else {
                assertionFailure()
                
                throw EmptyError()
            }
            
            return .init()
        }
        
        let filteredElements = elements.removing(elementsAtIndices: directChildren.map({ $0.offset }))
                
        return Children(
            try directChildren.lazy.map { (index, element) in
                Self(
                    value: element[keyPath: value],
                    children: try _makeChildren(
                        from: filteredElements,
                        parentID: element[keyPath: id],
                        id: id,
                        parent: parent,
                        value: value
                    )
                )
            }
        )
    }
}

extension HomogenousTree {
    public func _dumpNodeParentRelationships<ID: Hashable>(
        id: (Self) -> ID
    ) -> _IdentifiedTreeNodeParentRelationshipsDump<TreeValue, ID> {
        var nodesByID: [ID: TreeValue] = [:]
        
        func traverse(
            _ node: Self,
            parentID: ID?
        ) -> [(id: ID, parentID: ID?)] {
            let nodeID = id(node)
            
            if nodesByID[nodeID] != nil {
                assertionFailure()
            }
            
            nodesByID[nodeID] = node.value
            
            let pairs: [[(id: ID, parentID: ID?)]] = node.children.map { child in
                traverse(child, parentID: nodeID)
            }
            
            let currentPair: (id: ID, parentID: ID?) = (nodeID, parentID)
            
            return [currentPair] + pairs.flatMap({ $0 })
        }
        
        let relationships = traverse(self, parentID: nil)
        
        return .init(
            nodesByID: nodesByID,
            relationships: relationships
        )
    }
}
