//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct BidirectionalMap<Left: Hashable, Right: Hashable>: CustomStringConvertible, NonDestroyingCollection, ImplementationForwardingMutableWrapper, Initiable, SequenceInitiableSequence, Store {
    public typealias Storage = Pair<[Left: Right], [Right: Left]>
    public typealias Value = [Left: Right]
    
    public typealias Element = Value.Element
    public typealias Index = Value.Index
    public typealias Iterator = Value.Iterator
    public typealias SubSequence = Value.SubSequence
    
    public private(set) var storage: Storage = .init()
    
    public var value: Value {
        get {
            return storage.value.0
        } set {
            self = .init(storage.value.0)
        }
    }
    
    public init(storage: Storage) {
        self.storage = storage
    }
    
    public init(_ value: Value) {
        self.init(SequenceOnly(value))
    }
    
    public init<S: Sequence>(_ value: S) where S.Element == Element {
        for (first, second) in value {
            let (a, b) = associate(first, second)
            
            assert(a != nil && b != nil, "\(_Self.self) duplicate keys while initializing")
        }
    }
}

// MARK: - Extensions -

extension BidirectionalMap {
    public typealias LeftValues = Dictionary<Left, Right>.Keys
    public typealias RightValues = Dictionary<Left, Right>.Values
    
    public var leftValues: LeftValues {
        return storage.value.0.keys
    }
    
    public var rightValues: RightValues {
        return storage.value.0.values
    }
    
    @discardableResult
    public mutating func associate(_ left: Left, _ right: Right) -> (Right?, Left?) {
        return (storage.value.0.updateValue(right, forKey: left), storage.value.1.updateValue(left, forKey: right))
    }
    
    @discardableResult
    public mutating func disassociate(left: Left) -> Right? {
        guard let right = storage.value.0.removeValue(forKey: left) else {
            return nil
        }
        
        storage.value.1.removeValue(forKey: right)
        
        return right
    }
    
    @discardableResult
    public mutating func disassociate(right: Right) -> Left? {
        guard let left = storage.value.1.removeValue(forKey: right) else {
            return nil
        }
        
        storage.value.0.removeValue(forKey: left)
        
        return left
    }
    
    public mutating func disassociateAll(keepCapacity: Bool = false) {
        storage.value.0.removeAll(keepingCapacity: keepCapacity)
        storage.value.1.removeAll(keepingCapacity: keepCapacity)
    }
}

extension BidirectionalMap {
    public subscript(left left: Left) -> Right? {
        get {
            return storage.value.0[left]
        } set {
            if let newValue = newValue {
                associate(left, newValue)
            } else {
                disassociate(left: left)
            }
        }
    }
    
    public subscript(left: Left) -> Right? {
        get {
            return self[left: left]
        } set {
            self[left: left] = newValue
        }
    }
    
    public subscript(right right: Right) -> Left? {
        get {
            return storage.value.1[right]
        } set {
            if let newValue = newValue {
                associate(newValue, right)
            } else {
                disassociate(right: right)
            }
        }
    }
    
    public subscript(right: Right) -> Left? {
        get {
            return self[right: right]
        } set {
            self[right: right] = newValue
        }
    }
}

extension BidirectionalMap {
    public func index(forLeft value: Left) -> Index? {
        return storage.value.0.index(forKey: value)
    }
    
    public func index(forValue value: Left) -> Index? {
        return index(forLeft: value)
    }
    
    public func index(forRight value: Right) -> Index? {
        guard let value = self[right: value] else {
            return nil
        }
        
        return index(forLeft: value)
    }
    
    public func index(forValue value: Right) -> Index? {
        return index(forRight: value)
    }
    
    public func index(forValue value: Either<Left, Right>) -> Index? {
        return value.reduce(index(forLeft:), index(forRight:))
    }
    
    @discardableResult
    public mutating func disassociate(atIndex index: Index) -> (Left, Right) {
        let (left, right) = storage.value.0.remove(at: index)
        storage.value.1.removeValue(forKey: right)
        return (left, right)
    }
}

// MARK: - Protocol Implementations -

extension BidirectionalMap: KeyExposingMutableDictionaryProtocol {
    public typealias DictionaryKey = Left
    public typealias DictionaryValue = Right
    
    public var keys: Dictionary<Left, Right>.Keys {
        storage.value.0.keys
    }
    
    public var values: Dictionary<Left, Right>.Values {
        storage.value.0.values
    }
    
    public var keysAndValues: Dictionary<Left, Right> {
        storage.value.0
    }
    
    public mutating func setValue(_ value: Right, forKey key: Left) {
        self[key] = value
    }
}

extension BidirectionalMap: ElementRemoveableDestructivelyMutableSequence {
    @discardableResult
    public mutating func remove(_ element: Element) -> Element? {
        let first = storage.value.1.removeValue(forKey: element.1)
        let second = storage.value.0.removeValue(forKey: element.0)
        
        if let first = first, let second = second {
            return (first, second)
        } else if first == nil && second == nil {
            return nil
        } else {
            assertionFailure()
            
            return nil
        }
    }
    
    public mutating func forEach<T>(mutating iterator: ((inout Element?) throws -> T)) rethrows {
        for element in self {
            var _element: Element! = element
            _ = try iterator(&_element)
            if _element == nil {
                remove(element)
            }
        }
    }
}

// MARK: - Conditional Conformances -

extension BidirectionalMap: Codable where Left: Codable, Right: Codable {
    public init(from decoder: Decoder) throws {
        self.init(try [Left: Right].init(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

extension BidirectionalMap: Hashable where Left: Hashable, Right: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

extension BidirectionalMap: Equatable where Left: Equatable, Right: Equatable {
    public static func == (lhs: BidirectionalMap, rhs: BidirectionalMap) -> Bool {
        return lhs.value == rhs.value
    }
}
