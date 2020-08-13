//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct Matrix<Element>: Initiable, ImplementationForwardingMutableStore, MutableCollection2 {
    public typealias Storage = [Element]

    public typealias Index = Storage.Index
    public typealias Iterator = Storage.Iterator
    public typealias SubSequence = Storage.SubSequence

    public var rowCount: Int = 0
    public var columnCount: Int = 0
    public var storage: Storage = []

    public init(rowCount: Int, columnCount: Int, storage: Storage) {
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.storage = storage
    }
    
    public init() {
        self.init(rowCount: 0, columnCount: 0, storage: [])
    }

    public init(storage: Storage) {
        let rowOrColumnCount = storage.count.toDouble().squareRoot().toInt()

        assert((rowOrColumnCount * rowOrColumnCount).toInt() == storage.count)

        self.rowCount = rowOrColumnCount
        self.columnCount = rowOrColumnCount
        self.storage = storage
    }

    public init(rowCount: Int, columnCount: Int, repeatedValue: Element) {
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.storage = .init(repeating: repeatedValue, count: rowCount * columnCount)
    }
}

// MARK: - Extensions -

extension Matrix {

}

// MARK: - Protocol Implementations -

extension Matrix: Codable where Element: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        rowCount = try container.decode(Int.self)
        columnCount = try container.decode(Int.self)
        storage = Array(capacity: rowCount * columnCount)

        for _ in 0..<count {
            storage.append(try container.decode(Element.self))
        }
    }

    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()

        try container.encode(rowCount)
        try container.encode(columnCount)

        for element in storage {
            try container.encode(element)
        }
    }
}

extension Matrix: Equatable where Element: Equatable {
    @inlinable
    public static func == (lhs: Matrix, rhs: Matrix) -> Bool {
        return true
            && lhs.rowCount == rhs.rowCount
            && lhs.columnCount == rhs.columnCount
            && lhs.storage == rhs.storage
    }
}

extension Matrix: Hashable where Element: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rowCount)
        hasher.combine(columnCount)
        hasher.combine(storage)
    }
}

extension Matrix: MutableRowMajorRectangularCollection {
    public typealias RowIndex = Int
    public typealias RowIndexDistance = RowIndex.Stride
    public typealias ColumnIndex = Int
    public typealias ColumnIndexDistance = RowIndex.Stride
    public typealias RectangularElement = SubSequence
    public typealias RectangularIterator = AnyIterator<RectangularElement>

    @inlinable
    public var startRowIndex: RowIndex {
        return 0
    }

    @inlinable
    public var endRowIndex: RowIndex {
        return startRowIndex + rowCount
    }

    @inlinable
    public var startColumnIndex: ColumnIndex {
        return 0
    }

    @inlinable
    public var endColumnIndex: ColumnIndex {
        return startColumnIndex + columnCount
    }

    @inlinable
    public func rowIndex(after index: RowIndex) -> RowIndex {
        assert(index != endRowIndex)

        return index.successor()
    }

    @inlinable
    public func columnIndex(after index: ColumnIndex) -> ColumnIndex {
        assert(index != endColumnIndex)

        return index.successor()
    }

    @inlinable
    public func index(forRow rowIndex: RowIndex, column columnIndex: ColumnIndex) -> Index {
        return (rowIndex * columnCount) + (columnIndex - startColumnIndex)
    }

    @inlinable
    public func range(forRow rowIndex: RowIndex) -> Range<Index> {
        let startIndex = index(forRow: rowIndex, column: startColumnIndex)
        let endIndex = startIndex + columnCount

        return startIndex..<endIndex
    }

    @inlinable
    public func makeRectangularIterator() -> AnyIterator<SubSequence> {
        return .init((startRowIndex..<endRowIndex).lazy.map({ self[row: $0] }).makeIterator())
    }
}
