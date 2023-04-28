//
// Copyright (c) Vatsal Manot
//

import Swallow

public enum RecursiveTreeIterators {
    public struct DepthFirstIterator<Tree: RecursiveHomogenousTree>: IteratorProtocol {
        private var base: AnyIterator<Tree>
        
        fileprivate init(root: Tree) {
            base = [root].depthFirstIterator(children: { $0.children })
        }
        
        public mutating func next() -> Tree? {
            base.next()
        }
    }
}

extension RecursiveHomogenousTree {
    public func makeDepthFirstIterator() -> RecursiveTreeIterators.DepthFirstIterator<Self> {
        .init(root: self)
    }
}

public enum TreeTraversalAlgorithmType {
    case breadthFirst
    case depthFirst
}

extension RecursiveHomogenousTree {
    public func values(
        traversal: TreeTraversalAlgorithmType
    ) -> TreeValuesTraversalSequence<Self> {
        .init(from: self, traversal: traversal)
    }
}

public struct TreeValuesTraversalSequence<Tree: RecursiveHomogenousTree>: Sequence {
    private let base: Tree
    private let traversal: TreeTraversalAlgorithmType
    
    init(from base: Tree, traversal: TreeTraversalAlgorithmType) {
        self.base = base
        self.traversal = traversal
    }
    
    public var count: Int {
        var count = 0
        
        base.forEachDepthFirst({ _ in count += 1 })
        
        return count
    }
    
    public func makeIterator() -> AnyIterator<Tree.TreeValue> {
        switch traversal {
            case .depthFirst:
                return AnyIterator(
                    AnySequence({ Array(element: base).depthFirstIterator(children: { $0.children }) })
                        .lazy
                        .map({ $0.value })
                        .makeIterator()
                )
            case .breadthFirst:
                return AnyIterator(
                    AnySequence({ Array(element: base).breadthFirstIterator(children: { $0.children }) })
                        .lazy
                        .map({ $0.value })
                        .makeIterator()
                )
        }
    }
}

public extension Sequence {
    /// Returns a depth-first iterator over all the elements in the sequence.
    @inlinable
    func depthFirstIterator<Children: Sequence>(
        children: @escaping (Element) -> (Children)
    ) -> AnyIterator<Element> where Children.Element == Element {
        var iterator = self.makeIterator()
        var childIterator: AnyIterator<Element>?
        
        return AnyIterator<Element> {
            if let childIterator = childIterator, let nextChild = childIterator.next() {
                return nextChild
            } else if let next = iterator.next() {
                childIterator = children(next).depthFirstIterator(children: children).makeIterator()
                return next
            } else {
                return nil
            }
        }
    }
    
    /// Returns a breadth-first iterator over all the elements in the sequence.
    @inlinable
    func breadthFirstIterator<Children: Sequence>(
        children: @escaping (Element) -> (Children)
    ) -> AnyIterator<Element> where Children.Element == Element {
        var iterator: AnyIterator<Element>? = AnyIterator<Element>(self.makeIterator())
        var queue: ArraySlice<AnyIterator<Element>> = []
        
        return AnyIterator<Element> {
            while let it = iterator {
                if let next = it.next() {
                    queue.append(AnyIterator<Element>(children(next).makeIterator()))
                    
                    return next
                }
                
                iterator = queue.popFirst()
            }
            
            return nil
        }
    }
}
