//
// Copyright (c) Vatsal Manot
//

import Swallow

public typealias IdentifierIndexedArrayOf<Element: Identifiable> = IdentifierIndexedArray<Element, Element.ID>

public struct IdentifierIndexedArray<Element, ID: Hashable>: AnyProtocol {
    private var base: OrderedDictionary<ID, Element>
    private var keyPath: KeyPath<Element, ID>
    
    public init(_ array: [Element] = [], id: KeyPath<Element, ID>) {
        self.keyPath = id
        
        base = OrderedDictionary(uniqueKeysWithValues: array.map({ (key: $0[keyPath: id], value: $0) }))
    }
    
    public init(_ array: [Element]) where Element: Identifiable, Element.ID == ID {
        self.init(array, id: \.id)
    }
    
    private func _idForElement(_ element: Element) -> ID {
        element[keyPath: keyPath]
    }
}

// MARK: - Conformances -

extension IdentifierIndexedArray: CustomStringConvertible {
    public var description: String {
        Array(base).description
    }
}

extension IdentifierIndexedArray: CustomDebugStringConvertible {
    public var debugDescription: String {
        Array(base).debugDescription
    }
}

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

extension IdentifierIndexedArray: MutableCollection, MutableSequence, RandomAccessCollection {
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
            base[index].value
        } set {
            base[index] = (_idForElement(newValue), newValue)
        }
    }
    
    public subscript(id identifier: ID) -> Element? {
        get {
            base.value(forKey: identifier)
        } set {
            if let index = base.index(forKey: identifier) {
                if let newValue = newValue {
                    self[index] = newValue
                } else {
                    base.remove(at: index)
                }
            } else {
                if let newValue = newValue {
                    base.updateValue(newValue, forKey: identifier)
                } else {
                    // do nothing
                }
            }
        }
    }
    
    public func index(of id: ID) -> Int? {
        base.index(forKey: id)
    }
}

extension IdentifierIndexedArray: RangeReplaceableCollection where Element: Identifiable, Element.ID == ID {
    public mutating func replaceSubrange<C: Collection>(
        _ subrange: Range<Int>,
        with newElements: C
    ) where C.Element == Element {
        var _base = Array(base)
        
        _base.replaceSubrange(subrange, with: newElements.map({ (_idForElement($0), $0) }))
        
        self.base = .init(uniqueKeysWithValues: _base)
    }
    
    public mutating func remove(_ element: Element) {
        self[id: element[keyPath: keyPath]] = nil
    }
    
    /// Updates a given identifiable element if already present, inserts it otherwise.
    public mutating func updateOrAppend(_ element: Element) {
        if let index = self.index(of: _idForElement(element)) {
            self[index] = element
        } else {
            self.append(element)
        }
    }
}

extension IdentifierIndexedArray: @unchecked Sendable where Element: Sendable, ID: Sendable {
    
}

extension IdentifierIndexedArray: Sequence {
    public func makeIterator() -> AnyIterator<Element> {
        .init(base.lazy.map({ $0.value }).makeIterator())
    }
}

extension IdentifierIndexedArray: Decodable where Element: Decodable, Element: Identifiable, Element.ID == ID {
    public init(from decoder: Decoder) throws {
        self.init(try decoder.singleValueContainer().decode([Element].self), id: \.id)
    }
}

extension IdentifierIndexedArray: Encodable where Element: Encodable, Element: Identifiable, Element.ID == ID {
    public func encode(to encoder: Encoder) throws {
        try base.map({ $0.value }).encode(to: encoder)
    }
}
