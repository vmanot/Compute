//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol ResizableHypergraph: DestructivelyMutableHypergraph, ExtensibleHypergraph {
    
}

// MARK: - Extensions -

extension ResizableHypergraph where Edge: InitiableDirectedHyperedge, Edge.StartVertices == Edge.EndVertices {
    @discardableResult
    public mutating func removeBidirectionalEdge(_ edge: Edge) -> (Edge, Edge)? {
        guard containsEdge(edge) && containsEdge(edge.reversedEdge) else {
            return nil
        }
        
        return (removeEdge(edge)!, removeEdge(edge.reversedEdge)!)
    }
}
