//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct DictionarySnapshotOfTree<Node: ConstructibleTree & RecursiveTree & Identifiable> {
    public let values: [Node.ID: Node.Value]
    public let childrenByParent: Set<ReferenceTree<Node.ID>>
    
    public init(from nodes: IdentifierIndexedArray<Node, Node.ID>) {
        var childrenByParent: [Node.ID: Set<Node.ID>] = [:]
        
        var nodeIDs: [Node.ID: ReferenceTree<Node.ID>] = [:]
        
        var allChildrenIDs: Set<Node.ID> = []
        
        for node in nodes {
            let childrenIDs = Set(node.children.map(\.id))
            
            childrenByParent[node.id] = childrenIDs
            
            allChildrenIDs.formUnion(childrenIDs)
        }
        
        let rootNodeIDs = Set(nodeIDs.keys).subtracting(allChildrenIDs)
        
        for (parentID, childrenIDs) in childrenByParent {
            let parentTree = nodeIDs[parentID, default: ReferenceTree(parentID)]
            
            nodeIDs[parentID] = parentTree
            
            for childID in childrenIDs {
                let childTree = nodeIDs[childID, default: ReferenceTree(childID)]
                nodeIDs[childID] = childTree
                parentTree.addChild(childTree)
            }
        }
        
        self.values = nodes.groupFirstOnly(by: \.id).mapValues({ $0.value })
        self.childrenByParent = Set(nodeIDs.filter({ rootNodeIDs.contains($0.key) }).values)
    }
}

extension DictionarySnapshotOfTree {
    public enum CodingKeys: String, CodingKey {
        case values
        case childrenByParent
    }
}

extension DictionarySnapshotOfTree: Encodable where Node.Value: Encodable, Node.ID: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(values, forKey: .values)
        try container.encode(childrenByParent, forKey: .childrenByParent)
    }
}

extension DictionarySnapshotOfTree: Decodable where Node.ID: Decodable, Node.Value: Decodable, Node.Children: SequenceInitiableSequence {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.values = try container.decode([Node.ID: Node.Value].self, forKey: .values)
        self.childrenByParent = try container.decode(Set<ReferenceTree<Node.ID>>.self, forKey: .childrenByParent)
    }
}

extension DictionarySnapshotOfTree where Node: RecursiveTree, Node.Children: SequenceInitiableSequence {
    public func convert() -> [Node] {
        childrenByParent.map {
            $0.map(Node.self, value: { values[$0]! })
        }
    }
}

extension ReferenceTree {
    public func map<T: ConstructibleTree & RecursiveTree & Identifiable>(
        _ type: T.Type,
        value: (Element) -> T.Value
    ) -> T where T.Children: SequenceInitiableSequence {
        return T(value: value(element), children: T.Children(self.children.map({ $0.map(type, value: value) })))
    }
}