//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct TreePath<Tree: TreeProtocol> where Tree.Children: Collection {
    public let path: [Tree.Children.Index]
    
    public init(_ path: [Tree.Children.Index] = []) {
        self.path = path
    }
    
    public func appending(_ index: Tree.Children.Index) -> TreePath<Tree> {
        return TreePath(path + [index])
    }
}

/*extension Tree {
    func mapWithPath() -> Tree<(T, path: TreePath<T>)> {
        return mapWithPath(path: TreePath())
    }
    
    private func mapWithPath(path: TreePath<T>) -> Tree<(T, path: TreePath<T>)> {
        let valueWithPath = (value, path)
        let mappedChildren = children.enumerated().map { (index, child) in
            child.mapWithPath(path: path.appending(index))
        }
        return Tree<(T, path: TreePath<T>)>(valueWithPath, children: mappedChildren)
    }
}*/

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
