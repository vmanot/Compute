//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public struct ArrayTree<T>: ConstructibleTree, HomogenousTree {
    public typealias Value = T
    public typealias Children = ArrayTreeChildren<T>
    
    public var value: Value
    public var children: Children
    
    public init(value: Value, children: Children = []) {
        self.value = value
        self.children = children
    }
    
    public init(
        _ value: TreeValue,
        children: () -> Children
    ) {
        self.init(value: value, children: children())
    }
}

// MARK: - Conformances

extension ArrayTree: Equatable where T: Equatable {
    
}

extension ArrayTree: Hashable where T: Hashable {
    
}

extension ArrayTree: Sendable where T: Sendable {
    
}

extension ArrayTree: ExpressibleByArrayLiteral where T: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: T.ArrayLiteralElement...) {
        self.init(value: .init(_arrayLiteral: elements))
    }
    
    public init(
        _ value: TreeValue,
        children: () -> [T.ArrayLiteralElement]
    ) {
        self.init(
            value: value,
            children: [.init(value: T.init(_arrayLiteral: children()), children: [])]
        )
    }
    
    public init(
        _ value: T.ArrayLiteralElement,
        children: () -> [T.ArrayLiteralElement]
    ) {
        self.init(.init(arrayLiteral: value), children: children)
    }
    
    public init(
        _ value: T.ArrayLiteralElement,
        child: () -> T.ArrayLiteralElement
    ) {
        self.init(.init(arrayLiteral: value), children: { [child()] })
    }
    
    public init(
        _ value: T.ArrayLiteralElement
    ) {
        self.init(.init(arrayLiteral: value), children: { [] })
    }
}

extension ArrayTree: ExpressibleByBooleanLiteral where T: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: T.BooleanLiteralType) {
        self.init(value: .init(booleanLiteral: value))
    }
}

extension ArrayTree: ExpressibleByFloatLiteral where T: ExpressibleByFloatLiteral {
    public init(floatLiteral value: T.FloatLiteralType) {
        self.init(value: .init(floatLiteral: value))
    }
}

extension ArrayTree: ExpressibleByIntegerLiteral where T: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: T.IntegerLiteralType) {
        self.init(value: .init(integerLiteral: value))
    }
}

extension ArrayTree: ExpressibleByUnicodeScalarLiteral, ExpressibleByExtendedGraphemeClusterLiteral, ExpressibleByStringLiteral where T: ExpressibleByStringLiteral {
    public init(stringLiteral value: T.StringLiteralType) {
        self.init(value: .init(stringLiteral: value))
    }
}
