//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct UndirectedHyperedgeImpl<Vertex: Hashable>: Hashable, UndirectedMutableHyperedge {
    public typealias Vertices = Set<Vertex>
    
    public var vertices: Vertices
    
    public init(vertices: Vertices) {
        self.vertices = vertices
    }
}

public struct DirectedHyperedgeImpl<Vertex: Hashable>: Hashable, DirectedMutableHyperedge {
    public typealias StartVertices = Set<Vertex>
    public typealias EndVertices = Set<Vertex>
    public typealias Vertices = StartVertices.JointSequenceType
    
    public var startVertices: StartVertices
    public var endVertices: EndVertices
    
    public init(startVertices: StartVertices, endVertices: EndVertices) {
        self.startVertices = startVertices
        self.endVertices = endVertices
    }
}

public struct UndirectedEdgeImpl<Vertex: Hashable>: CustomStringConvertible, Hashable, VertexPairInitiable, UndirectedMutableEdge {
    public typealias StartVertices = CollectionOfOne<Vertex>
    public typealias EndVertices = CollectionOfOne<Vertex>
    public typealias Vertices = StartVertices.JointSequenceType
    
    public var startVertex: Vertex
    public var endVertex: Vertex
    
    public init(startVertex: Vertex, endVertex: Vertex) {
        self.startVertex = startVertex
        self.endVertex = endVertex
    }
}

public struct DirectedEdgeImpl<Vertex: Hashable>: CustomStringConvertible, Hashable, VertexPairInitiable, DirectedMutableEdge {
    public typealias StartVertices = CollectionOfOne<Vertex>
    public typealias EndVertices = CollectionOfOne<Vertex>
    public typealias Vertices = StartVertices.JointSequenceType
    
    public var startVertex: Vertex
    public var endVertex: Vertex
    
    public init(startVertex: Vertex, endVertex: Vertex) {
        self.startVertex = startVertex
        self.endVertex = endVertex
    }
}

// MARK: -

public struct HypergraphImpl<Vertex: Hashable, Edge: Hyperedge & Hashable>: AdditionOperatable, SubtractionOperatable, Initiable, ResizableHypergraph where Edge.Vertex == Vertex {
    public typealias Vertices = Set<Vertex>
    public typealias Edges = Set<Edge>
    
    public var vertices: Vertices
    public var edges: Edges
    
    public init() {
        vertices = []
        edges = []
    }
        
    public mutating func addVertex(_ vertex: Vertex) {
        vertices.insert(vertex)
    }
    
    public mutating func addEdge(_ edge: Edge) {
        vertices.insert(contentsOf: edge.vertices)
        edges.insert(edge)
    }
    
    @discardableResult public mutating func removeVertex(_ vertex: Vertex) -> Vertex? {
        edges.remove(contentsOf: edges.lazy.filter({ $0.contains(vertex) }))
        
        return vertices.remove(vertex)
    }
    
    @discardableResult public mutating func removeEdge(_ edge: Edge) -> Edge? {
        return edges.remove(edge)
    }
}

// MARK: - Protocol Implementations -

extension HypergraphImpl: CustomStringConvertible {
    public var description: String {
        return "\(vertices) : \(edges)"
    }
}

extension HypergraphImpl: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(vertices)
        hasher.combine(edges)
    }
}

extension HypergraphImpl: ExtensibleSequence {
    public typealias Element = (Vertex, Edges)
    public typealias Iterator = LazyMapCollection<Vertices, Element>.Iterator
    
    public mutating func insert(_ element: Element) {
        addVertex(element.0)
        
        element.1.forEach({ self.addEdge($0) })
    }
    
    public mutating func append(_ element: Element) {
        insert(element)
    }

    public func makeIterator() -> Iterator {
        return vertices.lazy.map({ vertex in (vertex, self.edges._filter({ $0.contains(vertex) })) }).makeIterator()
    }
}
