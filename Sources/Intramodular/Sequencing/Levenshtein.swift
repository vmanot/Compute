//
// Copyright (c) Vatsal Manot
//

import Swift

public struct MinumumEditDistanceCalculator<Element: Equatable> {
    class EditOperationChain {
        private(set) var current: EditOperation
        private(set) var previousChain: EditOperationChain? = nil
        private(set) var distance: Int = 0
        
        init(current: EditOperation, previousChain: EditOperationChain? = nil) {
            self.current = current
            self.previousChain = previousChain
            
            self.distance = (self.previousChain?.distance ?? 0) + current.distance
        }
    }
    
    public enum EditOperation {
        case delete(index: Int)
        case insert(index: Int, element: Element)
        case substitute(index: Int, element: Element)
        case doNothing
        
        public var distance: Int {
            switch self {
                case .doNothing:
                    return 0
                default:
                    return 1
            }
        }
    }
    
    public let before: [Element]
    public let after: [Element]
    
    public init(before: [Element], after: [Element]) {
        self.before = before
        self.after = after
    }
    
    public init<S: Sequence>(before: S, after: S) where S.Element == Element {
        self.before = .init(before)
        self.after = .init(after)
    }
    
    public func solve() -> [EditOperation] {
        var matrix = Matrix<EditOperationChain?>(
            rowCount: self.before.count + 1,
            columnCount: self.after.count + 1,
            repeatedValue: nil
        )
        
        matrix[column: 0, row: 0] = EditOperationChain(
            current: .doNothing
        )
        
        // Deletions
        if self.before.count > 0 {
            for i in 1...self.before.count {
                matrix[column: i, row: 0] = EditOperationChain(
                    current: .delete(index: 0/*i - 1*/),
                    previousChain: matrix[column: i - 1, row: 0]
                )
            }
        }
        
        // Insertions
        if self.after.count > 0 {
            for j in 1...self.after.count {
                matrix[column: 0, row: j] = EditOperationChain(
                    current: .insert(index: 0/*j - 1*/, element: self.after[j - 1]),
                    previousChain: matrix[column: 0, row: j - 1]
                )
            }
        }
        
        if self.before.count > 0 && self.after.count > 0 {
            for i in 1...self.before.count {
                for j in 1...self.after.count {
                    
                    if self.before[i - 1] == self.after[j - 1] {
                        matrix[column: i, row: j] = matrix[column: i - 1, row: j - 1]
                        continue
                    }
                    
                    let variants = [
                        matrix[column: i - 1, row: j]!,  // deletion
                        matrix[column: i, row: j - 1]!,  // insertion
                        matrix[column: i - 1, row: j - 1]!  // substitution
                    ] as [EditOperationChain]
                    
                    let distances = variants.map { $0.distance }
                    let minimumIndex = distances.firstIndex(of: distances.min()!)!
                    let minimumEditChain = variants[minimumIndex]
                    
                    var editChain: EditOperationChain? = nil
                    switch minimumIndex {
                        case 0:
                            // Deletion
                            editChain = EditOperationChain(current: .delete(index: j), previousChain: minimumEditChain)
                            break
                        case 1:
                            // Insertion
                            editChain = EditOperationChain(current: .insert(index: j - 1, element: self.after[j - 1]), previousChain: minimumEditChain)
                            break
                        case 2:
                            // Substitution
                            editChain = EditOperationChain(current: .substitute(index: j - 1, element: self.after[j - 1]), previousChain: minimumEditChain)
                            break
                        default:
                            assertionFailure()
                    }
                    
                    matrix[column: i, row: j] = editChain
                }
            }
        }
        
        var currentChain: EditOperationChain? = matrix[column: self.before.count, row: self.after.count]
        
        var editOperations: [EditOperation] = []
        
        while currentChain != nil {
            let editOperation = currentChain!.current
            
            switch editOperation {
                case .doNothing:
                    break
                default:
                    editOperations.insert(editOperation, at: 0)
                    break
            }
            
            currentChain = currentChain!.previousChain
        }
        
        return editOperations
    }
}
