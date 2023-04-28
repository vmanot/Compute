//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct TreePath<Tree: TreeProtocol>: Equatable where Tree.Children: Collection {
    public let path: [Tree.Children.Index]
    
    public init(_ path: [Tree.Children.Index] = []) {
        self.path = path
    }
    
    public func appending(_ index: Tree.Children.Index) -> TreePath<Tree> {
        return TreePath(path + [index])
    }
}

extension TreePath: Hashable where Tree.Children.Index: Hashable {
    
}

extension TreePath: Sendable where Tree.Children.Index: Sendable {
    
}

extension RecursiveHomogenousTree where Children: Collection {
    public func _enumerated() -> ArrayTree<(path: TreePath<Self>, value: TreeValue)> {
        return _enumerated(path: TreePath())
    }
    
    private func _enumerated(
        path: TreePath<Self>
    ) -> ArrayTree<(path: TreePath<Self>, value: TreeValue)> {
        return ArrayTree(
            value: (path, value),
            children: children.enumerated().map { (index, child) in
                child._enumerated(path: path.appending(index))
            }
        )
    }
}
 
extension RecursiveHomogenousTree where Children: Collection {
    public subscript(treePath: TreePath<Self>) -> Self? {
        var currentTree = self
        
        for index in treePath.path {
            if currentTree.children.indices.contains(index) {
                currentTree = currentTree.children[index]
            } else {
                return nil
            }
        }
        
        return currentTree
    }
}
