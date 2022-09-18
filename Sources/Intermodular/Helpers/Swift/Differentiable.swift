//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol Differentiable {
    associatedtype Difference
    
    func difference(from _: Self) -> Difference
    func applying(_: Difference) -> Self?
    
    mutating func applyUnconditionally(_: Difference)
}

// MARK: - Implementation -

extension Differentiable {
    public mutating func applyUnconditionally(_ difference: Difference) {
        self = applying(difference)!
    }
}
