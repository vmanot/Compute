//
// Copyright (c) Vatsal Manot
//

import Swallow

/// A sequence whose elements are laid out in a row & column layout.
///
/// e.g. `Matrix` is a `RectangularCollection`.
public protocol RectangularCollection: Collection {
    associatedtype RowIndex = Int
    associatedtype RowIndexDistance = Int
    
    associatedtype ColumnIndex = Int
    associatedtype ColumnIndexDistance = Int
    
    associatedtype RectangularIterator: IteratorProtocol
    associatedtype RectangularElement where Self.RectangularElement == RectangularIterator.Element
    
    var startRowIndex: Index { get }
    var endRowIndex: Index { get }
    
    var rowCount: Int { get }
    
    var startColumnIndex: Index { get }
    var endColumnIndex: Index { get }
    
    var columnCount: Int { get }
    
    func rowIndex(after _: RowIndex) -> RowIndex
    func columnIndex(after _: ColumnIndex) -> ColumnIndex
    func index(forRow _: RowIndex, column _: ColumnIndex) -> Index
    
    subscript(row _: Index, column _: Index) -> Element { get }
    
    func makeRectangularIterator() -> RectangularIterator
}

/// A rectangular collection that supports subscript assignment.
public protocol MutableRectangularCollection: MutableCollection, RectangularCollection {
    subscript(row _: Index, column _: Index) -> Element { get set }
}

// MARK: - Implementation -

extension RectangularCollection {
    public var count: Int {
        return rowCount * columnCount
    }
    
    public subscript(row rowIndex: RowIndex, column columnIndex: ColumnIndex) -> Element {
        return self[index(forRow: rowIndex, column: columnIndex)]
    }
}

extension MutableRectangularCollection  {
    public subscript(row rowIndex: RowIndex, column columnIndex: ColumnIndex) -> Element {
        get {
            return self[index(forRow: rowIndex, column: columnIndex)]
        } set {
            self[index(forRow: rowIndex, column: columnIndex)] = newValue
        }
    }
}
