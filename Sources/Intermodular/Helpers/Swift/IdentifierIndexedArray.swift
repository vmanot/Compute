//
// Copyright (c) Vatsal Manot
//

import Swift

public struct IdentifierIndexedArray<Element: Identifiable> {
    private var base: Array<Element> = []
    private var identifierToElementMap: [Element.ID: Int] = [:]
    
    public init(_ array: [Element]) {
        setBase(array)
    }
    
    private mutating func setBase(_ array: [Element]) {
        base = array
        identifierToElementMap = [:]
        
        for (index, element) in base.enumerated() {
            identifierToElementMap[element.id] = index
        }
    }
}

// MARK: - Conformances -

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
        base[index]
    }
    
    public subscript(bounds: Range<Int>) -> Array<Element>.SubSequence {
        base[bounds]
    }
    
    public subscript(id identifier: Element.ID) -> Element? {
        identifierToElementMap[identifier].map({ base[$0] })
    }
}

extension IdentifierIndexedArray: Sequence {
    public func makeIterator() -> AnyIterator<Element> {
        .init(base.makeIterator())
    }
}

extension IdentifierIndexedArray: Decodable where Element: Decodable {
    public init(from decoder: Decoder) throws {
        self.init(try Array<Element>(from: decoder))
    }
}

extension IdentifierIndexedArray: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        try base.encode(to: encoder)
    }
}
