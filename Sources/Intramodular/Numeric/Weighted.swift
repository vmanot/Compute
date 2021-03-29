//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A weighted type.
public protocol Weighted {
    associatedtype Weight: Numeric
    
    var weight: Weight { get }
}

/// A weighted type whose weight can be changed.
public protocol MutableWeighted: Weighted {
    var weight: Weight { get set }
}

// MARK: - Conformances -

public struct WeightedValue<Value, Weight: Numeric>: Weighted, PropertyWrapper {
    public let wrappedValue: Value
    public let weight: Weight
    
    public init(_ wrappedValue: Value, weight: Weight) {
        self.wrappedValue = wrappedValue
        self.weight = weight
    }
    
    public init(_ value: Value) {
        self.init(value, weight: 0)
    }
}
