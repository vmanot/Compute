//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol Tree {
    associatedtype Children: Sequence where Children.Element: Tree
    associatedtype Element where Child.Element == Element
    
    typealias Child = Children.Element
    
    var parent: Self? { get }
    var element: Element { get }
    var children: Children { get }
}

public protocol MutableTree: Tree where Children: MutableSequence {
    var element: Element { get set }
    var children: Children { get set }
}
