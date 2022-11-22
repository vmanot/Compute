//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol DestructivelyMutableHypergraph: MutableHypergraph {
    @discardableResult mutating func removeVertex(_: Vertex) -> Vertex?
    
    mutating func removeVertices(_: Vertices)
    mutating func removeVertices<S: Sequence>(_: S) where S.Element == Vertex
    mutating func removeVertices<C: Collection>(_: C) where C.Element == Vertex
    mutating func removeVertices<BC: BidirectionalCollection>(_: BC) where BC.Element == Vertex
    mutating func removeVertices<RAC: RandomAccessCollection>(_: RAC) where RAC.Element == Vertex
    
    @discardableResult mutating func removeEdge(_: Edge) -> Edge?
    
    mutating func removeEdges(_: Edges)
    mutating func removeEdges<S: Sequence>(_: S) where S.Element == Edge
    mutating func removeEdges<C: Collection>(_: C) where C.Element == Edge
    mutating func removeEdges<BC: BidirectionalCollection>(_: BC) where BC.Element == Edge
    mutating func removeEdges<RAC: RandomAccessCollection>(_: RAC) where RAC.Element == Edge
}

// MARK: - Implementation -

extension DestructivelyMutableHypergraph {
    public mutating func removeVertices<S: Sequence>(_ vertices: S) where S.Element == Vertex {
        vertices.forEach({ self.removeVertex($0) })
    }
    
    public mutating func removeEdges<S: Sequence>(_ edges: S) where S.Element == Edge {
        edges.forEach({ self.removeEdge($0) })
    }
}

// MARK: - Auxiliary -

extension DestructivelyMutableHypergraph {
    public func removingVertex(_ vertex: Vertex) -> Self {
        return build(self, with: { $0.removeVertex(vertex) })
    }
    
    public func removingVertices<S: Sequence>(_ vertices: S) -> Self where S.Element == Vertex {
        return build(self, with: { $0.removeVertices(vertices) })
    }
    
    public func removingEdge(_ edge: Edge) -> Self {
        return build(self, with: { $0.removeEdge(edge) })
    }
    
    public func removingEdges<S: Sequence>(_ edges: S) -> Self where S.Element == Edge {
        return build(self, with: { $0.removeEdges(edges) })
    }
}

// MARK: - Extensions -

extension DestructivelyMutableHypergraph where Edges.Element: VertexPairInitiable {
    @discardableResult public mutating func removeEdge(from startVertex: Vertex, to endVertex: Vertex) -> Edge? {
        return removeEdge(.init(startVertex: startVertex, endVertex: endVertex))
    }
}

// MARK: - Conformances -

extension DestructivelyMutableHypergraph where Self: SubtractionOperatable {
    public static func - (lhs: Self, rhs: Vertex) -> Self {
        return lhs.removingVertex(rhs)
    }
    
    public static func -= (lhs: inout Self, rhs: Vertex) {
        lhs.removeVertex(rhs)
    }
    
    public static func - (lhs: Self, rhs: Edge) -> Self {
        return lhs.removingEdge(rhs)
    }
    
    public static func -= (lhs: inout Self, rhs: Edge) {
        lhs.removeEdge(rhs)
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        return lhs.removingEdges(rhs.edges).removingVertices(lhs.vertices)
    }
    
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs.removeEdges(lhs.edges)
        lhs.removeVertices(lhs.vertices)
    }
}
