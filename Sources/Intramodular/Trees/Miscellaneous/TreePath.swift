//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct TreeIndexPath<Tree: TreeProtocol>: Equatable where Tree.Children: Collection {
    public let indices: [Tree.Children.Index]
    
    public init(indices: [Tree.Children.Index] = []) {
        self.indices = indices
    }
    
    public func appending(_ index: Tree.Children.Index) -> Self {
        Self(indices: indices + [index])
    }
}

extension TreeIndexPath: Hashable where Tree.Children.Index: Hashable {
    
}

extension TreeIndexPath: Sendable where Tree.Children.Index: Sendable {
    
}

extension HomogenousTree where Children: Collection {
    public func _enumerated() -> ArrayTree<(path: TreeIndexPath<Self>, value: TreeValue)> {
        return _enumerated(path: TreeIndexPath())
    }
    
    private func _enumerated(
        path: TreeIndexPath<Self>
    ) -> ArrayTree<(path: TreeIndexPath<Self>, value: TreeValue)> {
        return ArrayTree(
            value: (path, value),
            children: children.enumerated().map { (index, child) in
                child._enumerated(path: path.appending(index))
            }
        )
    }
}

extension HomogenousTree where Children: Collection {
    public var chains: TreeChains<Self> {
        TreeChains(root: self)
    }
    
    public subscript(path: TreeIndexPath<Self>) -> Self? {
        var currentTree = self
        
        for index in path.indices {
            if currentTree.children.indices.contains(index) {
                currentTree = currentTree.children[index]
            } else {
                return nil
            }
        }
        
        return currentTree
    }
}

public struct TreeChains<Tree: HomogenousTree>: Sequence where Tree.Children: Collection {
    public typealias Element = [Tree]
    
    fileprivate let root: Tree
    
    public var _naiveArrayValue: [Element] {
        root._allChains()
    }
    
    public subscript(_ path: TreeIndexPath<Tree>) -> Element {
        root._chain(for: path)
    }
    
    public func makeIterator() -> AnyIterator<Element> {
        .init(_naiveArrayValue.makeIterator())
    }
}

extension TreeChains: Collection {
    public typealias Index = Array<Element>.Index
    
    public var startIndex: Index {
        _naiveArrayValue.startIndex
    }
    
    public var endIndex: Index {
        _naiveArrayValue.endIndex
    }
    
    public subscript(position: Index) -> Element {
        _naiveArrayValue[position]
    }
}

extension TreeChains: CustomStringConvertible {
    public var description: String {
        _naiveArrayValue.description
    }
}

extension HomogenousTree where Children: Collection {
    fileprivate func _chain(
        for path: TreeIndexPath<Self>
    ) -> [Self] {
        var current: Self? = self
        var chain: [Self] = []
        
        for index in path.indices {
            guard let child = current?.children[index] else {
                return []
            }
            
            chain.append(child)
            
            current = child
        }
        
        return chain
    }
    
    fileprivate func _allChains(
        till shouldStopAt: (Self) throws -> Bool
    ) rethrows -> [TreeChains<Self>.Element] {
        var result: [TreeChains<Self>.Element] = []
        var currentChain: [Self] = []
        
        func depthFirstSearch(_ node: Self) throws {
            currentChain.append(node)
            
            if node.children.isEmpty {
                result.append(currentChain) // Reached a leaf node, add the current path to the resul
            } else {
                // Continue searching for paths in the child nodes
                for child in node.children {
                    guard try !shouldStopAt(child) else {
                        result.append(currentChain)
                        
                        break
                    }
                    
                    try depthFirstSearch(child)
                }
            }
            
            // Backtrack to the parent node
            currentChain.removeLast()
        }
        
        try depthFirstSearch(self)
        
        return result
    }
    
    fileprivate func _allChains() -> [TreeChains<Self>.Element] {
        _allChains(till: { _ in false })
    }
}

/*struct TreeChainsIterator<Tree: HomogenousTree>: IteratorProtocol where Tree.Children: Collection {
    public typealias Element = [Tree]
    
    let base: Tree
    var result: [[Element]] = []
    var currentChain: Element = []
    let terminator: (Tree) throws -> Bool
    
    mutating func next() -> [Tree]? {
        var result: [Element] = []
        
        depthFirstSearch(base)
    }
    
    mutating func depthFirstSearch(_ node: Tree) -> {
        currentChain.append(node)
        
        if node.children.isEmpty {
            result.append(currentChain) // Reached a leaf node, add the current path to the resul
        } else {
            // Continue searching for paths in the child nodes
            for child in node.children {
                guard try !terminator(child) else {
                    result.append(currentChain)
                    
                    break
                }
                
                try depthFirstSearch(child)
            }
        }
        
        // Backtrack to the parent node
        currentChain.removeLast()
    }
    
    try depthFirstSearch(self)
}
*/
