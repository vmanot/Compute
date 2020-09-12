//
// Copyright (c) Vatsal Manot
//

import Swallow

/*extension Collection where Element: Hashable, SubSequence: Hashable, SubSequence.Index == Index {
    public func ranges(of subsequence: SubSequence) -> [Range<Index>] {
        var elementBeforeAfter: [Element: (index: Index, before: Element?, after: Element?)] = [:]
        
        let indexedTokens = Array(subsequence.indices.zip(subsequence))
        
        for (index, indexedToken) in indexedTokens.enumerated() {
            let tokenIndex = indexedToken.0
            let token = indexedToken.1
            
            elementBeforeAfter[token] = (tokenIndex, before: indexedTokens[try: index - 1]?.1, after: indexedTokens[try: index + 1]?.1)
        }
        
        var lastElement: Element? = nil
        var startIndex: Index?
        
        for element in subsequence {
            if let lastElement = lastElement {
                
            }
        }
    }
}*/

public struct SequenceTokenizer<S: NonDestroyingCollection> where S.SubSequence: Hashable & SequenceInitiableSequence, S.Element: Hashable {
    public var tokens: Set<S.SubSequence> = []
    
    public init() {
        
    }
    
    private func isToken(_ subSequence: S.SubSequence) -> Bool {
        tokens.contains(subSequence)
    }
    
    private func isTokenPrefix(_ element: S.Element) -> Bool {
        tokens.contains(where: { $0.hasPrefix(element) })
    }
    
    public func input(_ sequence: S) -> [S.SubSequence] {
        var possibleTokens: [(S.Index, S.SubSequence)] = []
        var ranges: [S.Index] = []
        
        for (index, element) in sequence.enumerated() {
            if isTokenPrefix(element) {
                possibleTokens.append((index, sequence[index..<sequence.index(after: index)]))
            }
            
            for (ti, te) in possibleTokens.enumerated() {
                possibleTokens[ti] = (te.0, sequence[sequence.startIndex..<sequence.index(after: index)])
            }
            
            if let (start, _) = possibleTokens.filter({ isToken($0.1) }).first {
                ranges += [start, sequence.index(after: index)]
                possibleTokens = []
            }
        }
        
        if ranges.count != 0 {
            if ranges.first != sequence.startIndex {
                ranges.insert(sequence.startIndex)
            }
            
            if ranges.last != sequence.endIndex {
                ranges.append(sequence.endIndex)
            }
        }
        
        return ranges
            .consecutives()
            .map({ $0..<$1 })
            .filter({ !$0.isEmpty })
            .map({ sequence[$0] })
    }
}
