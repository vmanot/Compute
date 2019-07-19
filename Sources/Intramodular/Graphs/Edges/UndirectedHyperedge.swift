//
// Copyright (c) Vatsal Manot
//

import Swallow
import Swift

public protocol UndirectedHyperedge: Hyperedge {
    
}

public protocol UndirectedMutableHyperedge: UndirectedHyperedge {
    var vertices: Vertices { get set }
}

public protocol VerticeSequenceInitiableHyperedge: UndirectedHyperedge {
    init(vertices: Vertices)
}

// MARK: - Protocol Implementations -

extension UndirectedHyperedge where Vertex: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(Set(vertices))
    }
}

extension UndirectedHyperedge where Self: Edge & CustomStringConvertible {
    public var description: String {
        return "[\(startVertex)]-[\(endVertex)]"
    }
}

extension UndirectedHyperedge where Self: Edge & Hashable, Vertex: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(Set([startVertex, endVertex]))
    }
}
