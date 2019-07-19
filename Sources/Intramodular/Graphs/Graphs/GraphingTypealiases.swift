//
// Copyright (c) Vatsal Manot
//

import Swallow
import Swift

// MARK: Undirected

public typealias UndirectedEdge = UndirectedHyperedge & Edge
public typealias UndirectedMutableEdge = UndirectedEdge & MutableEdge
public typealias DirectedEdge = DirectedHyperedge & Edge
public typealias DirectedMutableEdge = DirectedHyperedge & MutableEdge

// MARK: Directed

public typealias Dihypergraph<V: Hashable> = HypergraphImpl<V, DirectedHyperedgeImpl<V>>
public typealias Digraph<V: Hashable> = HypergraphImpl<V, DirectedEdgeImpl<V>>
public typealias Uhypergraph<V: Hashable> = HypergraphImpl<V, UndirectedHyperedgeImpl<V>>
public typealias Ugraph<V: Hashable> = HypergraphImpl<V, UndirectedEdgeImpl<V>>
