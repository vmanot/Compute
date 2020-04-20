//
// Copyright (c) Vatsal Manot
//

import Swallow
import Swallow
import Swift

public struct RecursiveArray<Unit>: ImplementationForwardingMutableWrapper, ExpressibleByArrayLiteral, RandomAccessCollection, ResizableCollection, RecursiveCollection, ResizableRecursiveSequence, SequenceInitiableRecursiveSequence {
    public typealias Value = [Either<Unit, RecursiveArray>]

    public typealias Element = Value.Element
    public typealias Index = Value.Index
    public typealias Iterator = Value.Iterator
    public typealias RecursiveIndex = DefaultRecursiveIndex<Index>
    public typealias RecursiveIndices = DefaultRecursiveIndices<Index>
    public typealias SubSequence = Value.SubSequence

    public private(set) var isUnit: Bool = false
    
    public var value: Value {
        didSet {
            isUnit &&= value.count == 1
            isUnit &&= value.first!.leftValue.isNotNil
        }
    }

    public init(_ value: Value) {
        self.init(value, isUnit: false)
    }

    private init(_ value: Value, isUnit: Bool) {
        self.value = value
        self.isUnit = isUnit
    }
    
    public init(unit: Unit) {
        self.init([.left(unit)], isUnit: true)
    }
    
    public init<S: Sequence>(_ sequence: S) where S.Element: EitherRepresentable, S.Element.LeftValue == Unit, S.Element.RightValue == RecursiveArray {
        self.init(sequence.map({ $0.eitherValue }), isUnit: false)
    }

    public subscript(_ index: Index) -> Element {
        return value[index]
    }
}

// MARK: - Protocol Implementations -

extension RecursiveArray: CustomDebugStringConvertible, CustomStringConvertible {
    public var description: String {
        return reduce(String.init(describing:), { String(describing: $0.value.map({ $0.reduce({ CustomStringConvertibleOnly($0 as Unit) }, { CustomStringConvertibleOnly($0 as RecursiveArray) }) })) })
    }
    
    public var debugDescription: String {
        return description
    }
}

extension RecursiveArray: EitherRepresentable {
    public typealias LeftValue = Unit
    public typealias RightValue = RecursiveArray

    public var eitherValue: EitherValue {
        return isUnit
            ? .init(leftValue: value.first!.leftValue!)
            : .init(rightValue: self)
    }

    public init(_ eitherValue: EitherValue) {
        self = eitherValue.reduce({ .init(unit: $0) }, { $0 })
    }
}

extension RecursiveArray: Initiable {
    public init() {
        self.init(.init())
    }
}

// MARK: - Helpers -

extension RecursiveArray {
    public typealias RecursiveNestResult = Void
    public typealias RecursiveFlattenResult = Void

    public mutating func nest() {
        self = [.right(self)]
    }

    public func nested() -> RecursiveArray {
        return build(self, with: { $0.nest() })
    }

    public mutating func raiseDroppingFirst() {
        guard !isUnit, count > 1 else {
            return
        }
        
        self = .init([first!, .right(.init(dropFirst()))])
    }
}

extension RecursiveArray {
    public subscript(recursive index: Index) -> RecursiveArray {
        get {
            return .init(self[index])
        } set {
            self[index] = .init(newValue.eitherValue)
        }
    }
}
