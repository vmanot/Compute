//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public struct ArrayTree<T>: RecursiveHomogenousTree {
    public typealias Value = T
    public typealias Children = Array<Self>
    
    public var value: Value
    public var children: Children
    
    public init(value: Value, children: Children = []) {
        self.value = value
        self.children = children
    }
}
