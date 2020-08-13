//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol Tree {
    var parent: Self? { get }
}

public protocol LeavedTree: Tree {
    associatedtype Leaves: Sequence where Leaf == Self

    typealias Leaf = Leaves.Element

    var children: Leaves { get }
}

public protocol MutableTree: Tree {

}

public protocol DepthTree: Tree {
    associatedtype Depth: Numeric

    var depth: Depth { get }
}
