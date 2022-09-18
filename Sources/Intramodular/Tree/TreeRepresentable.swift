//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol TreeRepresentable: Identifiable {
    associatedtype TreeRepresentation: Tree
    
    init(treeRepresentation: TreeRepresentation)
}
