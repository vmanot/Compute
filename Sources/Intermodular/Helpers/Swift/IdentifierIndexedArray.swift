//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct IdentifierIndexedArray<Element, ID: Hashable>: AnyProtocol {
    private var base: Array<Element> = [] {
        didSet {
            reindex()
        }
    }
    private var keyPath: KeyPath<Element, ID>
    private var identifierToElementMap: [ID: Int] = [:]
    
    public init(_ array: [Element], id: KeyPath<Element, ID>) {
        self.keyPath = id
        
        setBase(array)
    }
    
    private mutating func setBase(_ array: [Element]) {
        base = array
        identifierToElementMap = [:]
        
        reindex()
    }
    
    private mutating func reindex() {
        identifierToElementMap = [:]
        
        for (index, element) in base.enumerated() {
            identifierToElementMap[element[keyPath: keyPath]] = index
        }
    }
}

// MARK: - Conformances -

extension IdentifierIndexedArray: ExpressibleByArrayLiteral where Element: Identifiable, Element.ID == ID {
    public init(arrayLiteral elements: Element...) {
        self.init(elements, id: \.id)
    }
}

extension IdentifierIndexedArray: Collection {
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
            base[index] = newValue
        }
    }
    
    public subscript(bounds: Range<Int>) -> Array<Element>.SubSequence {
        get {
            base[bounds]
        } set {
            base[bounds] = newValue
        }
    }
    
    public subscript(id identifier: ID) -> Element? {
        identifierToElementMap[identifier].map({ base[$0] })
    }
}

extension IdentifierIndexedArray: Initiable where Element: Identifiable, Element.ID == ID {
    public init() {
        self.init([], id: \.id)
    }
}

extension IdentifierIndexedArray: RangeReplaceableCollection where Element: Identifiable, Element.ID == ID {
    public mutating func replaceSubrange<C: Collection>(
        _ subrange: Range<Int>,
        with newElements: C
    ) where C.Element == Element {
        base.replaceSubrange(subrange, with: newElements)
        
        reindex()
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
