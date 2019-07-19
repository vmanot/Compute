//
// Copyright (c) Vatsal Manot
//

import Swallow
import Swift

open class AbstractNode<Owner: AnyObject> {
    public private(set) weak var owner: Owner?
    public private(set) weak var parent: AbstractNode?

    public var isOwned: Bool {
        return owner != nil
    }

    public var root: AbstractNode? {
        var parent = self.parent

        while let _parent = parent {
            parent = _parent
        }

        return parent
    }

    private(set) var depth: Int = 0

    open func attach(_ owner: Owner) {
        self.owner = owner
    }

    open func redepthChildren() {
        
    }

    open func redepth(_ child: AbstractNode) {
        assert(child.owner === owner)

        if (child.depth <= depth) {
            child.depth = depth + 1
            child.redepthChildren()
        }
    }

    open func adopt(_ child: AbstractNode) {
        assert(child.parent == nil)

        assert {
            if let root = root {
                return !(root === child)
            } else {
                return true
            }
        }

        child.parent = self
        owner.map(child.attach)
    }

    open func drop(_ child: AbstractNode) {
        assert(child.parent === self)

        child.parent = nil

        if child.isOwned {
            child.detach()
        }
    }

    open func detach() {
        assert(owner != nil)
        owner = nil
        assert(parent == nil || isOwned == parent!.isOwned)
    }
}
