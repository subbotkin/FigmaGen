//
//  Node.swift
//  FigmaGen
//
//  Created by Alexey Subbotkin on 23/09/2018.
//  Copyright © 2018 Alexey Subbotkin. All rights reserved.
//

import Foundation

enum NodeType: String, Decodable {
    case document = "DOCUMENT"
    case canvas = "CANVAS"
    case vector = "VECTOR"
    case group = "GROUP"
    case frame = "FRAME"
    case text = "TEXT"
    case rectangle = "RECTANGLE"
    case component = "COMPONENT"
    case instance = "INSTANCE"
}

enum Node: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(NodeType.self, forKey: .type)
        
        switch type {
        case .document:
            let document = try Document(from: decoder)
            self = .document(document)
        case .canvas:
            let canvas = try Canvas(from: decoder)
            self = .canvas(canvas)
        case .vector:
            self = .vector(try Vector(from: decoder))
        case .group:
            self = .group(try Group(from: decoder))
        case .frame:
            self = .frame(try Frame(from: decoder))
        case .rectangle:
            self = .rectangle(try Rectangle(from: decoder))
        case .component:
            self = .component(try ComponentNode(from: decoder))
        case .text:
            self = .text(try Text(from: decoder))
        case .instance:
            self = .instance(try Instance(from: decoder))
        }
    }
    
    case document(Document)
    case canvas(Canvas)
    case vector(Vector)
    case group(Group)
    case frame(Frame)
    case text(Text)
    case rectangle(Rectangle)
    case component(ComponentNode)
    case instance(Instance)
}

protocol ContainerNode {
    var children: [Node] { get }
}

protocol ColorNode {
    var backgroundColor: Color? { get }
}

protocol BoundedNode {
    var absoluteBoundingBox: Rect { get }
}

protocol VectorNode: BoundedNode {
    var fills: [Paint] { get }
   
}

protocol ConstrainedNode {
    var constraints: LayoutConstraint { get }
}

struct LayoutConstraint: Decodable {
    enum Vertical: String, Decodable {
        case top = "TOP"
        case bottom = "BOTTOM"
        case center = "CENTER"
        case topBottom = "TOP_BOTTOM"
        case scale = "SCALE"
    }
    
    enum Horizontal: String, Decodable {
        case left = "LEFT"
        case right = "RIGHT"
        case center = "CENTER"
        case leftRight = "LEFT_RIGHT"
        case scale = "SCALE"
    }
    
    let vertical: Vertical
    let horizontal: Horizontal
}


protocol BaseNode {
    var id: String { get }
    var name: String { get }
    var visible: Bool? { get }
}

struct Paint: Decodable {
    enum PaintType: String, Decodable {
        case solid = "SOLID"
        case gradientLinear = "GRADIENT_LINEAR"
        case gradientRadial = "GRADIENT_RADIAL"
        case gradientAngular = "GRADIENT_ANGULAR"
        case gradientDiamond = "GRADIENT_DIAMOND"
        case image = "IMAGE"
        case emoji = "EMOJI"
    }
    
    let color: Color
    let opacity: Double?
    let visible: Bool?
}

struct Frame: BaseNode, ContainerNode, ConstrainedNode, Decodable {
    var id: String
    var name: String
    var visible: Bool?
    var children: [Node]
    var constraints: LayoutConstraint
}

struct ComponentNode: BaseNode, ContainerNode, ConstrainedNode, Decodable {
    var id: String
    var name: String
    var visible: Bool?
    var children: [Node]
    var constraints: LayoutConstraint
}

struct Instance: BaseNode, ContainerNode, ConstrainedNode, Decodable {
    var id: String
    var name: String
    var visible: Bool?
    var children: [Node]
    var constraints: LayoutConstraint
}

struct Group: BaseNode, ContainerNode, ConstrainedNode, Decodable {
    var id: String
    var name: String
    var visible: Bool?
    var children: [Node]
    var constraints: LayoutConstraint
}

struct Vector: BaseNode, VectorNode, Decodable {
    var id: String
    var name: String
    var visible: Bool?
    var fills: [Paint]
    var absoluteBoundingBox: Rect
}

struct Text: BaseNode, Decodable {
    var id: String
    var name: String
    var visible: Bool?
    var characters: String
}

struct Rectangle: BaseNode, VectorNode, ColorNode, Decodable {
    var id: String
    var name: String
    var visible: Bool?
    var cornerRadius: Double
    var fills: [Paint]
    var absoluteBoundingBox: Rect
    
    var backgroundColor: Color? {
        return fills.first?.color
    }
}

struct Document: BaseNode, ContainerNode, Decodable {
    var id: String
    var name: String
    var visible: Bool?
    var children: [Node]
}

extension Document {
    var node: Node {
        return .document(self)
    }
}

struct Canvas: BaseNode, ContainerNode, Decodable {
    var id: String
    var name: String
    var visible: Bool?
    var children: [Node]
}

struct Color: Decodable {
    var r: Double
    var g: Double
    var b: Double
    var a: Double
}

struct Rect: Decodable {
    var x: Double
    var y: Double
    var width: Double
    var height: Double
}

extension Node {
    var allNodes: [Node] {
        guard let children = children else {
            return [self]
        }
        
        var allChildren = [Node]()
        for child in children {
            allChildren = allChildren + (child.allNodes)
        }
        
        return allChildren + [self]
    }
}
extension Node {
    var children: [Node]? {
        return (baseNode as? ContainerNode)?.children
    }
    
    var component: ComponentNode? {
        guard case .component(let component) = self else {
            return nil
        }
        
        return component
    }
}

extension Node {
    var baseNode: BaseNode {
        switch self {
        case .document(let document): return document
        case .canvas(let canvas): return canvas
        case .vector(let vector): return vector
        case .group(let group): return group
        case .frame(let frame): return frame
        case .text(let text): return text
        case .rectangle(let rectangle): return rectangle
        case .component(let component): return component
        case .instance(let instance): return instance
        }
    }
}
