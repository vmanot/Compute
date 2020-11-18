//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol Tree {
    associatedtype Children: Sequence where Children.Element: Tree
    associatedtype Element = Never where Child.Element == Element
    
    typealias Child = Children.Element
    
    var element: Element { get }
    var children: Children { get }
}

public protocol MutableTree: Tree where Children: MutableSequence {
    var element: Element { get set }
    var children: Children { get set }
}

public protocol RecursiveTree: Tree where Child == Self {
    
}

public protocol ParentPointerTree: RecursiveTree {
    var parent: Self { get }
}

// MARK: - Implementation -

extension Tree where Element == Never {
    public var element: Never {
        fatalError()
    }
}

extension MutableTree where Element == Never {
    public var element: Never {
        get {
            fatalError()
        } set {
            
        }
    }
}
