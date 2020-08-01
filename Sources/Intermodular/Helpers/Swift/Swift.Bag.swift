//
// Copyright (c) Vatsal Manot
//

import Swallow

protocol BagProtocol: Sequence {
    associatedtype ElementKey

    mutating func insert(_ element: Element) -> ElementKey
    mutating func removeElement(forKey _: ElementKey) -> Element?
}

// MARK: - Concrete Implementations -

fileprivate let arrayDictionaryMaxSize = 30

public struct BagKey: Equatable, Hashable {
    fileprivate let rawValue: UInt64
}

public struct Bag<Element>: BagProtocol {
    public typealias KeyType = BagKey
    public typealias Entry = (key: BagKey, value: Element)
    
    private var nextKey = BagKey(rawValue: 0)
    private var key0: BagKey?
    private var value0: Element?
    private var pairs = ContiguousArray<Entry>()
    private var dictionary: [BagKey : Element]?
    private var onlyFastPath = true

    public init() {
        
    }
    
    public var count: Int {
        let dictionaryCount = dictionary?.count ?? 0
        
        return 0
            + (value0 != nil ? 1 : 0)
            + pairs.count
            + dictionaryCount
    }

    public mutating func insert(_ element: Element) -> BagKey {
        let key = nextKey
        
        nextKey = BagKey(rawValue: nextKey.rawValue &+ 1)
        
        if key0 == nil {
            key0 = key
            value0 = element
            return key
        }
        
        onlyFastPath = false
        
        if dictionary != nil {
            dictionary![key] = element
            return key
        }
        
        if pairs.count < arrayDictionaryMaxSize {
            pairs.append((key: key, value: element))
            return key
        }
        
        dictionary = [key: element]
        
        return key
    }
    
    public mutating func removeElement(forKey key: BagKey) -> Element? {
        if key0 == key {
            key0 = nil
            let value = value0!
            value0 = nil
            return value
        }
        
        if let existingObject = dictionary?.removeValue(forKey: key) {
            return existingObject
        }
        
        for i in 0..<pairs.count {
            if pairs[i].key == key {
                let value = pairs[i].value
                pairs.remove(at: i)
                return value
            }
        }
        
        return nil
    }
    
    public mutating func removeAll(keepingCapacity: Bool = false) {
        key0 = nil
        value0 = nil
        
        pairs.removeAll(keepingCapacity: keepingCapacity)
        dictionary?.removeAll(keepingCapacity: keepingCapacity)
    }
}

extension Bag: CustomDebugStringConvertible {
    public var debugDescription : String {
        return "\(self.count) elements in Bag"
    }
}

extension Bag: Sequence {
    public func forEach(_ action: ((Element) throws -> Void)) rethrows {
        try value0.map(action)
        
        guard !onlyFastPath else {
            return
        }
        
        try pairs.forEach({ try action($0.value )})
        try dictionary?.values.forEach(action)
    }
    
    public mutating func forEach(mutating action: ((inout Element) throws -> Void)) rethrows {
        try value0.mutate(action)
        
        guard !onlyFastPath else {
            return
        }
        
        try pairs.forEach(mutating: { try action(&$0.value )})
        try dictionary?.forEach(mutating: { try action(&$0.value) })
    }

    public func makeIterator() -> AnyIterator<Element> {
        if let value0 = value0 {
            let value0Collection = CollectionOfOne(value0)
            if onlyFastPath {
                return .init(value0Collection.makeIterator())
            }
            if pairs.count > 0 {
                let pairsValues = pairs.lazy.map { $0.value }
                if let dictionary = dictionary, dictionary.count > 0 {
                    let dictionaryValues = dictionary.values
                    return .init(
                        value0Collection
                            .join(pairsValues)
                            .join(dictionaryValues)
                            .makeIterator()
                    )
                } else {
                    return .init(value0Collection.join(pairsValues).makeIterator())
                }
            } else {
                return .init(value0Collection.makeIterator())
            }
        } else {
            return .init(EmptyCollection<Element>().makeIterator())
        }
    }
}
