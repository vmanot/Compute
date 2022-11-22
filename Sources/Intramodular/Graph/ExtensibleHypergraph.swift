//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol ExtensibleHypergraph: Hypergraph {
    associatedtype VertexAdditionResult = Void
    associatedtype VerticesAdditionResult = Void

    @discardableResult mutating func addVertex(_: Vertex) -> VertexAdditionResult
    
    @discardableResult mutating func addVertices(_: Vertices) -> VerticesAdditionResult
    @discardableResult mutating func addVertices<S: Sequence>(_: S) -> VerticesAdditionResult where S.Element == Vertex
    @discardableResult mutating func addVertices<C: Collection>(_: C) -> VerticesAdditionResult where C.Element == Vertex
    @discardableResult mutating func addVertices<BC: BidirectionalCollection>(_: BC) -> VerticesAdditionResult where BC.Element == Vertex
    @discardableResult mutating func addVertices<RAC: RandomAccessCollection>(_: RAC) -> VerticesAdditionResult where RAC.Element == Vertex
    
    associatedtype EdgeAdditionResult = Void
    associatedtype EdgesAdditionResult = Void

    @discardableResult mutating func addEdge(_: Edge) -> EdgeAdditionResult
    
    @discardableResult mutating func addEdges(_: Edges) -> EdgesAdditionResult
    @discardableResult mutating func addEdges<S: Sequence>(_: S) -> EdgesAdditionResult where S.Element == Edge
    @discardableResult mutating func addEdges<C: Collection>(_: C) -> EdgesAdditionResult where C.Element == Edge
    @discardableResult mutating func addEdges<BC: BidirectionalCollection>(_: BC) -> EdgesAdditionResult where BC.Element == Edge
    @discardableResult mutating func addEdges<RAC: RandomAccessCollection>(_: RAC) -> EdgesAdditionResult where RAC.Element == Edge
}

// MARK: - Implementation -

extension ExtensibleHypergraph where VertexAdditionResult == Void, VerticesAdditionResult == Void {
    public mutating func addVertices<S: Sequence>(_ vertices: S) where S.Element == Vertex {
        vertices.forEach({ self.addVertex($0) })
    }
    
    public mutating func addEdges<S: Sequence>(_ edges: S) where S.Element == Edge {
        edges.forEach({ self.addEdge($0) })
    }
}

// MARK: - Auxiliary -

extension ExtensibleHypergraph {
    public func addingVertex(_ vertex: Vertex) -> Self {
        return build(self, with: { $0.addVertex(vertex) })
    }
    
    public func addingVertices<S: Sequence>(_ vertices: S) -> Self where S.Element == Vertex {
        return build(self, with: { $0.addVertices(vertices) })
    }
    
    public func addingEdge(_ edge: Edge) -> Self {
        return build(self, with: { $0.addEdge(edge) })
    }
    
    public func addingEdges<S: Sequence>(_ edges: S) -> Self where S.Element == Edge {
        return build(self, with: { $0.addEdges(edges) })
    }
}

// MARK: - Extensions -

extension ExtensibleHypergraph where Edges.Element: VertexPairInitiable {
    public mutating func addEdge(from startVertex: Vertex, to endVertex: Vertex) {
        addEdge(.init(startVertex: startVertex, endVertex: endVertex))
    }
    
    public static func += (lhs: inout Self, rhs: (Vertex, Vertex)) {
        lhs.addEdge(from: rhs.0, to: rhs.1)
    }
}

extension ExtensibleHypergraph where Edges.Element: DirectedEdge & VertexPairInitiable {
    public mutating func addBidirectionalEdge(_ edge: Edge) {
        addEdge(edge)
        addEdge(edge.reversedEdge)
    }
}

// MARK: - Conformances -

extension ExtensibleHypergraph where Self: AdditionOperatable {
    public static func + (lhs: Self, rhs: Vertex) -> Self {
        return lhs.addingVertex(rhs)
    }
    
    public static func += (lhs: inout Self, rhs: Vertex) {
        lhs.addVertex(rhs)
    }
    
    public static func + (lhs: Self, rhs: Edge) -> Self {
        return lhs.addingEdge(rhs)
    }
    
    public static func += (lhs: inout Self, rhs: Edge) {
        lhs.addEdge(rhs)
    }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        return lhs.addingVertices(rhs.vertices).addingEdges(rhs.edges)
    }
    
    public static func += (lhs: inout Self, rhs: Self) {
        lhs.addVertices(rhs.vertices)
        lhs.addEdges(rhs.edges)
    }
}
