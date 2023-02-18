//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol DirectedGraphEdge<Vertex> {
    associatedtype Vertex
    
    typealias Vertices = DAGEdgeVertexPair<Vertex>
}

/// An type that represents an edge in a directed acyclic graph.
public protocol DirectedAcyclicGraphEdge<Vertex>: DirectedGraphEdge {
    
}

// MARK: - Auxiliary

/// The payload of a DAG edge.
public struct DAGEdgeVertexPair<Vertex> {
    public let source: Vertex
    public let destination: Vertex
    
    public init(source: Vertex, destination: Vertex) {
        self.source = source
        self.destination = destination
    }
}
