//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct Multimap<T: Hashable, U: Hashable>: MutableWrapper {
    public typealias Value = [T: Set<U>]
    
    public var value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}

// MARK: - Conformances -

extension Multimap: CustomStringConvertible {
    public var description: String {
        return describe(value)
    }
}

extension Multimap: ExtensibleSequence {
    public mutating func insert(_ element: Element) {
        self[element.0, default: .init()] += element.1
    }
    
    public mutating func append(_ element: Element) {
        self[element.0, default: .init()] += element.1
    }
}

extension Multimap: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value.map(Hasher.finalizedHashValue))
    }
}

extension Multimap: Initiable {
    public init() {
        self.init(Value())
    }
}

extension Multimap: MutableDictionaryProtocol {
    public typealias DictionaryKey = T
    public typealias Keys = Value.Keys
    public typealias DictionaryValue = Set<U>
    public typealias Values = [U]
    
    public var keys: Keys {
        return value.keys
    }
    
    public var values: Values {
        return value.values.flatMap(id)
    }
    
    public subscript(key: DictionaryKey) -> DictionaryValue? {
        get {
            return value[key]
        } set {
            value[key] = newValue
        }
    }
    
    public subscript(value value: U) -> Set<T>? {
        let result = Set(keys.filter({ self[$0]?.contains(value) ?? false }))
        
        guard !result.isEmpty else {
            return nil
        }
        
        return result
    }
}

extension Multimap: SequenceInitiableSequence {
    public typealias Iterator = FlattenSequence<LazyMapCollection<[T : Set<U>], LazyMapCollection<Set<U>, (T, U)>>>.Iterator
    
    public init<S: Sequence>(_ sequence: S) where S.Element == Element {
        self.init()
        
        sequence.forEach({ self[$0.0, default: .init()] += $0.1 })
    }
    
    public func makeIterator() -> Iterator {
        return value.lazy.flatMap({ (key, value) in value.lazy.map({ (key, $0) }) }).makeIterator()
    }
}
