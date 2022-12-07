//
// Copyright (c) Vatsal Manot
//

import Swallow

extension Array: Differentiable where Element: Equatable {
    public typealias Difference = CollectionDifference<Element>
}

extension ArraySlice: Differentiable where Element: Equatable {
    public typealias Difference = CollectionDifference<Element>
}

extension ContiguousArray: Differentiable where Element: Equatable {
    public typealias Difference = CollectionDifference<Element>
}

public struct DictionaryDifference<Key: Hashable, Value>: Sequence {
    public enum Change {
        case insert(key: Key, value: Value)
        case update(key: Key, value: Value)
        case remove(key: Key)
        
        var key: Key {
            switch self {
                case .insert(let key, _):
                    return key
                case .update(let key, _):
                    return key
                case .remove(let key):
                    return key
            }
        }
        
        var value: Value? {
            switch self {
                case .insert(_, let value):
                    return value
                case .update(_, let value):
                    return value
                case .remove:
                    return nil
            }
        }
    }
    
    public var insertions: [Change]
    public var updates: [Change]
    public var removals: [Change]
    
    public var isEmpty: Bool {
        insertions.isEmpty && updates.isEmpty && removals.isEmpty
    }

    public init(insertions: [Change], updates: [Change], removals: [Change]) {
        self.insertions = insertions
        self.updates = updates
        self.removals = removals
    }
    
    public mutating func merge(_ change: Change) {
        insertions.removeAll(where: { $0.key == change.key })
        updates.removeAll(where: { $0.key == change.key })
        removals.removeAll(where: { $0.key == change.key })

        switch change {
            case .insert:
                insertions.append(change)
            case .update:
                updates.append(change)
            case .remove:
                removals.append(change)
        }
    }
    
    public subscript(_ key: Key) -> Value? {
        get {
            if removals.contains(where: { $0.key == key }) {
                return nil
            } else {
                return insertions.join(updates).first(where: { $0.key == key })?.value
            }
        } set {
            if let newValue = newValue {
                merge(.update(key: key, value: newValue))
            } else {
                merge(.remove(key: key))
            }
        }
    }
    
    public func makeIterator() -> AnyIterator<Change> {
        return .init((insertions + updates + removals).makeIterator())
    }
}

extension Dictionary: Differentiable where Value: Equatable {
    public typealias Difference = DictionaryDifference<Key, Value>
    
    public func difference(from other: Dictionary) -> Difference {
        var insertions: [Difference.Change] = []
        var updates: [Difference.Change] = []
        var removals: [Difference.Change] = []
        
        var checkedPairs = self
        
        for (otherKey, otherValue) in other {
            if let value = checkedPairs[otherKey] {
                if value != otherValue {
                    updates += .update(key: otherKey, value: value)
                }
            } else {
                removals += .remove(key: otherKey)
            }
            
            checkedPairs.removeValue(forKey: otherKey)
        }
        
        insertions = checkedPairs.keysAndValues.map({ .insert(key: $0.key, value: $0.value) })
        
        return .init(insertions: insertions, updates: updates, removals: removals)
    }
    
    public mutating func applyUnconditionally(_ difference: Difference) {
        for change in difference {
            switch change {
                case let .insert(key, value):
                    assert(index(forKey: key) == nil)
                    self[key] = value
                case let .update(key, value):
                    assert(index(forKey: key) != nil)
                    self[key] = value
                case let .remove(key):
                    assert(index(forKey: key) != nil)
                    removeValue(forKey: key)
            }
        }
    }
    
    public func applying(_ difference: Difference) -> Dictionary? {
        return build(self, with: { $0.applyUnconditionally($1) }, difference)
    }
}

extension Result: Differentiable where Success: Differentiable {
    public typealias Difference = Result<Success.Difference, Failure>
    
    public func difference(from other: Result) -> Result<Success.Difference, Failure> {
        switch (self, other) {
            case let (.success(x), .success(y)):
                return .success(x.difference(from: y))
            case let (.failure(x), _):
                return .failure(x)
            case let (_, .failure(y)):
                return .failure(y)
        }
    }
    
    public func applying(_ difference: Difference) -> Result? {
        switch (self, difference) {
            case let (.success(x), .success(y)):
                return x.applying(y).map(Result.success)
            case let (.failure(x), _):
                return .failure(x)
            case let (_, .failure(y)):
                return .failure(y)
        }
    }
    
    public mutating func applyUnconditionally(_ difference: Difference) {
        switch (self, difference) {
            case (var .success(x), let .success(y)):
                x.applyUnconditionally(y)
                self = .success(x)
            case let (.failure(x), _):
                self = .failure(x)
            case let (_, .failure(y)):
                self = .failure(y)
        }
    }
}

extension Slice: Differentiable where Base: BidirectionalCollection & RangeReplaceableCollection, Element: Equatable {
    public typealias Difference = CollectionDifference<Element>
}

extension String: Differentiable {
    public typealias Difference = CollectionDifference<Element>
}

extension Substring: Differentiable {
    public typealias Difference = CollectionDifference<Element>
}
