//
// Copyright (c) Vatsal Manot
//

import Swallow
import Swift

public protocol Weighted {
    associatedtype Weight: Numeric
    
    var weight: Weight { get }
}

public protocol MutableWeighted: Weighted {
    var weight: Weight { get set }
}

// MARK: - Protocol Implementations -

@frozen
public struct WeightedWrapper<Value, Weight: Numeric>: Weighted, Wrapper {
    public let value: Value
    public let weight: Weight
    
    public init(_ value: Value, weight: Weight) {
        self.value = value
        self.weight = weight
    }
    
    public init(_ value: Value) {
        self.init(value, weight: 0)
    }
}
