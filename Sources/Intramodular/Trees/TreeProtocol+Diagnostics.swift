//
// Copyright (c) Vatsal Manot
//

import Swallow

extension TreeProtocol {
    public func dumpTree() -> String {
        _dumpTree()
    }
    
    private func _dumpTree(
        indentation: String = "",
        isLastChild: Bool = true
    ) -> String {
        var result = ""
        let prefix: String
        
        result += "\(String(describing: value))\n"
        
        if isLastChild {
            prefix = "\(indentation)└── "
        } else {
            prefix = "\(indentation)├── "
        }
        
        let childIndentation = isLastChild ? indentation + "    " : indentation + "│   "
        
        for (index, child) in children.enumerated() {
            result += "\(prefix)\(child._dumpTree(indentation: childIndentation, isLastChild: index == children.underestimatedCount - 1))"
        }
        
        return result
    }
}
