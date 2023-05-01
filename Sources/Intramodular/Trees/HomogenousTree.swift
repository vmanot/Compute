//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol HomogenousTree: RecursiveTreeProtocol where Children.Element == Self {
    
}

extension HomogenousTree where Self: Hashable, TreeValue: Hashable, Children: Collection, Children.Index: Hashable {
    public func hash(into hasher: inout Hasher) {
        for node in AnySequence({ _enumerated().makeDepthFirstIterator() }) {
            node.value.path.hash(into: &hasher)
            node.value.value.hash(into: &hasher)
        }
    }
}

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
