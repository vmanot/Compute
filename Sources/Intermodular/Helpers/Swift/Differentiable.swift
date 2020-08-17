//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol _opaque_Differentiable {

}

public protocol Differentiable: _opaque_Differentiable {
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
