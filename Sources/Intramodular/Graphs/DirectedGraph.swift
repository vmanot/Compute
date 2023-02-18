//
// Copyright (c) Vatsal Manot
//

import Swallow
import Swift

public protocol DirectedGraph {
    associatedtype Vertex
    associatedtype Edge: DirectedGraphEdge<Vertex>
    
    associatedtype Vertices: Collection where Vertices.Element == Vertex
    associatedtype Edges: Collection where Edges.Element == Edge
    
    var vertices: Vertices { get }
    var edges: Edges { get }
    
    func vertices(for edge: Edge) -> Edge.Vertices
}

public protocol DestructivelyMutableDirectedGraph: DirectedGraph {
    func removeVertex(at index: Vertices.Index)
    func removeVertices(at indices: some Sequence<Vertices.Index>)
    func removeEdge(at index: Edges.Index)
    func removeEdges(at index: some Sequence<Edges.Index>)
}
