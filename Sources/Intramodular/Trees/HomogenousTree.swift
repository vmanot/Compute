//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol HomogenousTree: RecursiveTreeProtocol where Children.Element == Self {
    
}

// MARK: - Constructors

extension HomogenousTree where Self: ConstructibleTree, Children: RangeReplaceableCollection {
    public init(
        value: TreeValue,
        recursiveChildren: some RandomAccessCollection<TreeValue>
    ) {
        var currentChild: Self?
        
        for child in recursiveChildren.reversed() {
            if let _currentChild = currentChild {
                currentChild = .init(value: child, children: [_currentChild])
            } else {
                currentChild = .init(value: child, children: [])
            }
        }
        
        self = .init(value: value, children: currentChild.map({ .init([$0]) }) ?? .init())
    }
    
    public init?(recursiveValues: some RandomAccessCollection<TreeValue>) {
        guard let first = recursiveValues.first else {
            return nil
        }
        
        self.init(value: first, recursiveChildren: recursiveValues.dropFirst())
    }
}

// MARK: - Extensions

extension HomogenousTree {
    public func recursiveFirst(
        where predicate: (TreeValue) -> Bool
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

// MARK: - Implemented Conformances

extension HomogenousTree where Self: Hashable, TreeValue: Hashable, Children: Collection, Children.Index: Hashable {
    public func hash(into hasher: inout Hasher) {
        for node in AnySequence({ _enumerated().makeDepthFirstIterator() }) {
            node.indexPath.hash(into: &hasher)
            node.value.hash(into: &hasher)
        }
    }
}
