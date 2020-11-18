//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol Hyperedge: Equatable {
    associatedtype Vertex: Equatable
    associatedtype Vertices: Sequence where Vertices.Element == Vertex
    
    var vertices: Vertices { get }
    
    func contains(_: Vertex) -> Bool
}

// MARK: - Implementation -

extension Hyperedge  {
    public func contains(_ vertex: Vertex) -> Bool {
        return vertices.contains(vertex)
    }
}

extension Hyperedge where Vertices: SetProtocol {
    public func contains(_ vertex: Vertex) -> Bool {
        return vertices.contains(vertex)
    }
}

// MARK: - Protocol Conformances -

extension Hyperedge where Vertex: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(HashableSequence(vertices))
    }
}
