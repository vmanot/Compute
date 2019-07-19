//
// Copyright (c) Vatsal Manot
//

import Swallow
import Swift

public protocol VertexPairInitiable {
    associatedtype Vertex: Equatable
    
    init(startVertex: Vertex, endVertex: Vertex)
}

// MARK: - Extensions -

extension VertexPairInitiable where Self: Edge {
    public var reversedEdge: Self {
        get {
            return .init(startVertex: endVertex, endVertex: startVertex)
        } set {
            self = .init(startVertex: newValue.endVertex, endVertex: newValue.startVertex)
        }
    }
}
