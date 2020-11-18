//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol Edge: Hyperedge {
    var startVertex: Vertex { get }
    var endVertex: Vertex { get }
}

public protocol MutableEdge: Edge {
    associatedtype Vertices = CollectionOfTwo<Vertex>
    
    var startVertex: Vertex { get set }
    var endVertex: Vertex { get set }
}

// MARK: - Precursory Implementation -

extension Hyperedge where Self: Edge, Vertices == CollectionOfTwo<Vertex> {
    public var vertices: Vertices {
        return CollectionOfOne(startVertex).join(CollectionOfOne(endVertex))
    }
}

extension Hyperedge where Self: MutableEdge, Vertices == CollectionOfTwo<Vertex> {
    public var vertices: Vertices {
        get {
            return CollectionOfOne(startVertex).join(CollectionOfOne(endVertex))
        } set {
            startVertex = newValue[0]
            endVertex = newValue[1]
        }
    }
}

extension DirectedHyperedge where Self: Edge, StartVertices == CollectionOfOne<Vertex>, EndVertices == CollectionOfOne<Vertex>, Vertices == CollectionOfTwo<Vertex> {
    public var startVertices: StartVertices {
        return .init(startVertex)
    }
    
    public var endVertices: StartVertices {
        return .init(endVertex)
    }
}

extension DirectedHyperedge where Self: MutableEdge, StartVertices == CollectionOfOne<Vertex>, EndVertices == CollectionOfOne<Vertex>, Vertices == CollectionOfTwo<Vertex> {
    public var startVertices: StartVertices {
        get {
            return .init(startVertex)
        } set {
            startVertex = newValue.first
        }
    }
    
    public var endVertices: StartVertices {
        get {
            return .init(endVertex)
        } set {
            endVertex = newValue.first
        }
    }
}

// MARK: - Extensions -

extension Edge  {
    public func contains(_ vertex: Vertex) -> Bool {
        return startVertex == vertex || endVertex == vertex
    }
}

// MARK: - Protocol Conformances -

extension DirectedHyperedge where Self: Edge {
    public var description: String {
        return "\(startVertex)→\(endVertex)"
    }
}
