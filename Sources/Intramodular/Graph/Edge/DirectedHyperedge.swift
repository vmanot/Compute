//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol DirectedHyperedge: Hyperedge {
    associatedtype StartVertices: Sequence where StartVertices.Element == Vertex
    associatedtype EndVertices: Sequence where EndVertices.Element == Vertex
    
    var startVertices: StartVertices { get }
    var endVertices: EndVertices { get }
}

public protocol DirectedMutableHyperedge: DirectedHyperedge {
    var startVertices: StartVertices { get set }
    var endVertices: EndVertices { get set }
}

public protocol InitiableDirectedHyperedge: DirectedHyperedge {
    init(startVertices: StartVertices, endVertices: EndVertices)
}

// MARK: - Precursory Implementation -

extension DirectedHyperedge where StartVertices: JoinableSequence, StartVertices == EndVertices, Vertices == StartVertices.JointSequenceType {
    public var vertices: Vertices {
        return startVertices.join(endVertices)
    }
}

// MARK: - Extensions -

extension InitiableDirectedHyperedge where StartVertices == EndVertices {
    public var reversedEdge: Self {
        return .init(startVertices: endVertices, endVertices: startVertices)
    }
}

// MARK: - Conformances -

extension DirectedHyperedge where Self: Hashable, Vertex: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(HashableSequence(startVertices))
        hasher.combine(HashableSequence(endVertices))
    }
}

extension DirectedHyperedge where Self: Edge & Hashable, Vertex: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(startVertex)
        hasher.combine(endVertex)
    }
}
