//
// Copyright (c) Vatsal Manot
//

import Swallow
import Swift

public protocol RowMajorRectangularCollection: RectangularCollection {    
    func range(forRow _: RowIndex) -> Range<Index>
    
    subscript(row _: Index) -> RectangularElement { get }
}

public protocol MutableRowMajorRectangularCollection: MutableRectangularCollection, RowMajorRectangularCollection {
    subscript(row _: Index) -> RectangularElement { get set }
}

// MARK: - Implementation -

extension RowMajorRectangularCollection where RectangularElement == SubSequence {
    @inlinable
    public subscript(row rowIndex: RowIndex) -> RectangularElement {
        return self[range(forRow: rowIndex)]
    }
}

extension MutableRowMajorRectangularCollection where RectangularElement == SubSequence {
    @inlinable
    public subscript(row rowIndex: RowIndex) -> RectangularElement {
        get {
            return self[range(forRow: rowIndex)]
        } set {
            self[range(forRow: rowIndex)] = newValue
        }
    }
}
