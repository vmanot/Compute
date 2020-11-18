//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol Hypergraph {
    associatedtype Vertex
    associatedtype Vertices: Sequence where Vertices.Element == Vertex
    associatedtype Edge: Hyperedge where Edge.Vertex == Vertices.Element
    associatedtype Edges: Sequence where Edges.Element == Edge
    
    var vertices: Vertices { get }
    var edges: Edges { get }
    
    func containsVertex(_: Vertex) -> Bool
    func containsEdge(_: Edge) -> Bool
}

public protocol MutableHypergraph: Hypergraph {
    var vertices: Vertices { get set }
    var edges: Edges { get set }
}

// MARK: - Implementation -

extension Hypergraph where Vertices: SetProtocol {
    public func containsVertex(_ vertex: Vertex) -> Bool {
        return vertices.contains(vertex)
    }
}

extension Hypergraph where Edges: SetProtocol {
    public func containsEdge(_ edge: Edge) -> Bool {
        return edges.contains(edge)
    }
}

// MARK: - Protocol Conformances -

extension Hypergraph where Vertices: Hashable, Edges: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(vertices)
        hasher.combine(edges)
    }
}
