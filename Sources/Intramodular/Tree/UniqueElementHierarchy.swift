//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct UniqueElementHierarchy<Element: Hashable>: Hashable, RecursiveTree {
    public var element: Element
    public var _children: [Element: UniqueElementHierarchy<Element>]
    
    public var children: AnySequence<UniqueElementHierarchy<Element>> {
        .init(_children.values)
    }
    
    public init(element: Element) {
        self.element = element
        self._children = [:]
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(element)
        hasher.combine(_children)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        true
            && lhs.element == rhs.element
            && lhs._children == rhs._children
    }
}

extension UniqueElementHierarchy {
    public subscript(element: Element) -> Self? {
        get {
            if element == self.element {
                return self
            } else {
                for (key, value) in _children {
                    if element == key {
                        return value
                    } else if let result = value[element] {
                        return result
                    }
                }
                
                return nil
            }
        } set {
            let didSet = setHierarchy(newValue, for: element)
            
            if !didSet {
                if let newValue = newValue {
                    if element == self.element {
                        self = newValue
                    } else {
                        _children[element] = newValue
                    }
                } else {
                    _children = [:]
                }
            }
        }
    }
    
    public subscript(
        element: Element,
        default defaultValue: @autoclosure () -> Self
    ) -> Self {
        get {
            self[element] ?? defaultValue()
        } set {
            self[element] = newValue
        }
    }
    
    private mutating func setHierarchy(_ newHierarchy: Self?, for element: Element) -> Bool {
        if element == self.element {
            if let newHierarchy = newHierarchy {
                self = newHierarchy
            } else {
                self.element = element
            }
            
            return true
        } else {
            var result = false
            
            for key in _children.keys {
                if element == key {
                    if let newHierarchy = newHierarchy {
                        _children[key] = newHierarchy
                        
                        return true
                    } else {
                        _children[key] = nil
                    }
                } else {
                    result ||= _children[key]!.setHierarchy(newHierarchy, for: element)
                }
                
                if result {
                    return result
                }
            }
            
            return result
        }
    }
}

// MARK: - Conditional Conformances -

extension UniqueElementHierarchy: CustomDebugStringConvertible where Element: CustomDebugStringConvertible {
    public var description: String {
        guard !_children.isEmpty else {
            return element.debugDescription
        }
        
        return String(describing: (element, Array(_children.values)))
    }
}

// MARK: - Protocol Conformances -

extension UniqueElementHierarchy: CustomStringConvertible {
    public var description: String {
        guard !_children.isEmpty else {
            return String(describing: element)
        }
        
        return String(describing: (element, Array(_children.values)))
    }
}
