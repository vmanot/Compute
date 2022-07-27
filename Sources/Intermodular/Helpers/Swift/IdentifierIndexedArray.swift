//
// Copyright (c) Vatsal Manot
//

import Swallow

public typealias IdentifierIndexedArrayOf<Element: Identifiable> = IdentifierIndexedArray<Element, Element.ID>

public struct IdentifierIndexedArray<Element, ID: Hashable>: AnyProtocol {
    private var base: Array<Element>
    private var keyPath: KeyPath<Element, ID>
    private var identifierToElementMap: [ID: Int]
    
    public init(_ array: [Element], id: KeyPath<Element, ID>) {
        self.keyPath = id
        
        base = array
        identifierToElementMap = [:]
        
        reindex(base.bounds)
    }
    
    public init(_ array: [Element]) where Element: Identifiable, Element.ID == ID {
        self.init(array, id: \.id)
    }
    
    private mutating func reindex(_ range: Range<Int>, remove: Bool = false) {
        for index in range {
            identifierToElementMap[base[index][keyPath: keyPath]] = remove ? nil : index
        }
    }
}

// MARK: - Conformances -

extension IdentifierIndexedArray: Equatable where Element: Equatable {
    
}

extension IdentifierIndexedArray: ExpressibleByArrayLiteral where Element: Identifiable, Element.ID == ID {
    public init(arrayLiteral elements: Element...) {
        self.init(elements, id: \.id)
    }
}

extension IdentifierIndexedArray: Hashable where Element: Hashable {
    
}

extension IdentifierIndexedArray: Initiable where Element: Identifiable, Element.ID == ID {
    public init() {
        self.init([], id: \.id)
    }
}

extension IdentifierIndexedArray: MutableCollection, RandomAccessCollection {
    public var count: Int {
        base.count
    }
    
    public var startIndex: Int {
        base.startIndex
    }
    
    public var endIndex: Int {
        base.endIndex
    }
    
    public subscript(_ index: Int) -> Element {
        get {
            base[index]
        } set {
            reindex(index..<(index + 1), remove: true)
            base[index] = newValue
            reindex(index..<(index + 1))
        }
    }
    
    public subscript(id identifier: ID) -> Element? {
        get {
            identifierToElementMap[identifier].map({ base[$0] })
        } set {
            if let index = identifierToElementMap[identifier] {
                if let newValue = newValue {
                    assert(base[index][keyPath: keyPath] == newValue[keyPath: keyPath])
                    
                    base[index] = newValue
                } else {
                    identifierToElementMap[base[index][keyPath: keyPath]] = nil
                    base.remove(at: index)
                }
            }
        }
    }
    
    public func index(of id: ID) -> Int? {
        identifierToElementMap[id]
    }
}

extension IdentifierIndexedArray: RangeReplaceableCollection where Element: Identifiable, Element.ID == ID {
    public mutating func replaceSubrange<C: Collection>(
        _ subrange: Range<Int>,
        with newElements: C
    ) where C.Element == Element {
        let haveSameLength = subrange.count == newElements.count
        
        // must be computed since `base` may change after base.replaceSubrange
        var targetRange: Range<Int> {
            haveSameLength ? subrange : subrange.startIndex..<base.endIndex
        }
        
        reindex(targetRange, remove: true)
        
        base.replaceSubrange(subrange, with: newElements)
        
        reindex(targetRange)
    }
    
    public mutating func remove(_ element: Element) {
        let id = element[keyPath: keyPath]
        
        guard let index = identifierToElementMap[id] else {
            return
        }
        
        identifierToElementMap[id] = nil
        
        base.remove(at: index)
    }
}

extension IdentifierIndexedArray: Sequence {
    public func makeIterator() -> AnyIterator<Element> {
        .init(base.makeIterator())
    }
}

extension IdentifierIndexedArray: Decodable where Element: Decodable, Element: Identifiable, Element.ID == ID {
    public init(from decoder: Decoder) throws {
        self.init(try decoder.singleValueContainer().decode([Element].self), id: \.id)
    }
}

extension IdentifierIndexedArray: Encodable where Element: Encodable, Element: Identifiable, Element.ID == ID {
    public func encode(to encoder: Encoder) throws {
        try base.encode(to: encoder)
    }
}
