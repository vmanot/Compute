//
// Copyright (c) Vatsal Manot
//

import Swallow

extension RecursiveTreeProtocol {
    public func map<T>(_ transform: (Value) -> T) -> ArrayTree<T> {
        let mappedValue = transform(value)
        let mappedChildren = children.map { $0.map(transform) }
        
        return ArrayTree(value: mappedValue, children: mappedChildren)
    }
}

extension RecursiveTreeProtocol {
    /// Visits each node in the tree in post-order traversal and applies the visit closure to the value of each node.
    public func traversePostOrder(
        _ visit: (Value) -> Void
    ) {
        for child in children {
            child.traversePostOrder(visit)
        }
        
        visit(value)
    }
}

extension RecursiveTreeProtocol {
    public func makePostOrderIterator() -> RecursiveTreeIterators.PostOrderIterator<Self> {
        .init(root: self)
    }
    
    public func makeDepthFirstIterator() -> RecursiveTreeIterators.DepthFirstIterator<Self> {
        .init(root: self)
    }
}

public enum RecursiveTreeIterators {
    /// An iterator that traverses a tree in post-order.
    public struct PostOrderIterator<Tree: RecursiveTreeProtocol>: IteratorProtocol {
        /// The stack of nodes to be processed.
        private var nodes: [AnyTreeNode<Tree.Value>]
        
        /// Creates a new post-order iterator starting at the root of the given tree.
        ///
        /// - Parameter root: The root of the tree to traverse.
        fileprivate init(root: Tree) {
            nodes = [root.eraseToAnyTreeNode()]
        }
        
        /// Returns the next value in the post-order traversal, or `nil` if all nodes have been processed.
        ///
        /// - Returns: The next value in the traversal, or `nil` if all nodes have been processed.
        public mutating func next() -> Tree.Value? {
            while let node = nodes.last {
                // If the current node has children, add the first child to the stack.
                if let childNode = node.children.first?.eraseToAnyTreeNode() {
                    nodes.append(childNode)
                } else {
                    // If the current node has no children, remove it from the stack and return its value.
                    nodes.removeLast()
                    return node.value
                }
            }
            
            // If there are no more nodes on the stack, the traversal is complete.
            return nil
        }
    }
    
    /// An iterator that traverses a tree in depth-first order.
    public struct DepthFirstIterator<Tree: RecursiveTreeProtocol>: IteratorProtocol {
        /// The stack of nodes to be processed.
        private var nodes: [AnyTreeNode<Tree.Value>]
        
        /// Creates a new depth-first iterator starting at the root of the given tree.
        ///
        /// - Parameter root: The root of the tree to traverse.
        fileprivate init(root: Tree) {
            // Add the children of the root node to the stack in reverse order, so they will be processed in the correct order.
            nodes = Array(root.children.map({ $0.eraseToAnyTreeNode() }).reversed())
        }
        
        /// Returns the next value in the depth-first traversal, or `nil` if all nodes have been processed.
        ///
        /// - Returns: The next value in the traversal, or `nil` if all nodes have been processed.
        public mutating func next() -> Tree.Value? {
            while !nodes.isEmpty {
                // Get the next node from the top of the stack.
                let node = nodes.removeLast()
                
                // Add the children of the current node to the stack in reverse order, so they will be processed in the correct order.
                nodes.append(contentsOf: node.children.map({ $0.eraseToAnyTreeNode() }).reversed())
                
                // Return the value of the current node.
                return node.value
            }
            
            // If there are no more nodes on the stack, the traversal is complete.
            return nil
        }
    }
}
