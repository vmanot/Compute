//
// Copyright (c) Vatsal Manot
//

import Swallow
import Swift

/// A directed acyclic graph.
public protocol DirectedAcyclicGraph: DirectedGraph where Edge: DirectedAcyclicGraphEdge<Vertex> {
    
}

public protocol MutableDirectedAcyclicGraph: DirectedAcyclicGraph {
    mutating func reserveCapacity(vertexCount: Int)
    mutating func addEdge(from source: Vertex, to destination: Vertex) -> Edge
    @discardableResult
    mutating func removeEdge(from u: Vertex, to v: Vertex) -> Bool
    mutating func remove(_ edge: Edge) -> Bool
    mutating func remove(_ vertex: Vertex)
}

public protocol DirectedAcyclicGraphAdjacency<Vertex>: Sequence {
    associatedtype Vertex
    associatedtype Vertices: Sequence where Vertices.Element == Vertices
    associatedtype Edge: DirectedAcyclicGraphEdge<Vertex>
    associatedtype Edges: Sequence where Edges.Element == Edge
    
    func vertices(adjacentTo vertex: Vertex) -> Edges
}
