//
// Copyright (c) Vatsal Manot
//

import Swallow

public enum _DirectedAcyclicGraphs {
    public struct EdgeList<Element: Identifiable>: DirectedAcyclicGraph {
        public struct Edge: DirectedAcyclicGraphEdge {
            public typealias Vertex = EdgeList.Vertex
            
            public let source: Vertex.ID
            public let destination: Vertex.ID
        }
        
        public typealias Vertex = Element
        
        public typealias Vertices = IdentifierIndexedArrayOf<Element>
        public typealias Edges = [Edge]
        
        public private(set) var vertices: Vertices
        public private(set) var edges: Edges
        
        private init(
            vertices: Vertices,
            edges: Edges
        ) {
            self.vertices = vertices
            self.edges = edges
        }
        
        public init() {
            self.init(vertices: [], edges: [])
        }
        
        public func vertices(for edge: Edge) -> Edge.Vertices {
            let source = vertices[id: edge.source]!
            let destination = vertices[id: edge.destination]!
            
            return .init(source: source, destination: destination)
        }
    }
}

extension _DirectedAcyclicGraphs.EdgeList: Codable where Element: Codable, Element.ID: Codable {
    private enum CodingKeys: String, CodingKey {
        case vertices
        case edges
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        vertices = try container.decode(Vertices.self, forKey: .vertices)
        edges = try container.decode(Edges.self, forKey: .edges)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(vertices, forKey: .vertices)
        try container.encode(edges, forKey: .edges)
    }
}

extension _DirectedAcyclicGraphs.EdgeList.Edge: Codable where Vertex.ID: Codable {
    
}
