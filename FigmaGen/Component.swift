//
//  Component.swift
//  FigmaGen
//
//  Created by Alexey Subbotkin on 23/09/2018.
//  Copyright © 2018 Alexey Subbotkin. All rights reserved.
//

import Foundation

@objcMembers
class View: NSObject {
    dynamic let name: String
    dynamic let subviews: [View]
    dynamic let style: ViewStyle
    init(name: String, subviews: [View], style: ViewStyle) {
        self.name = name
        self.subviews = subviews
        self.style = style
    }
    
    dynamic var render: [String] {
        return self.render(depth: 0)
    }
    
    func body() -> [String] {
        return []
    }
    
    private func render(depth: Int) -> [String] {
        let offset = String.init(repeating: "  ", count: depth)
        var result = [offset + "<\(name) style={styles.\(style.name)}>\n"]
        for subview in subviews {
            result += subview.render(depth: depth + 1)
        }
        for bodyLine in body() {
            result += [offset + "  " + bodyLine]
        }
        result += [offset + "</\(name)>\n"]
        
        return result
    }
    
    func renderStyle() -> [String] {
        var lines = ["\(style.name): {"]
        for property in style.properties {
            lines += ["  \(property.key): \(property.value.string),"]
        }
        lines += ["},"]
        
        for subview in subviews {
            lines += subview.renderStyle()
        }
        
        return lines
    }
}

final class TextView: View {
    
    let text: String
    init(text: String, subviews: [View], style: ViewStyle) {
        self.text = text
        super.init(name: "Text", subviews: subviews, style: style)
    }
    
    override func body() -> [String] {
        return [text]
    }
}

extension Node {
    var view: View {
        switch self {
        case .document(let document): return View(
            name: "View",
            subviews: document.children.map({ $0.view }),
            style: self.style
            )
        case .canvas(let canvas): return View(
            name: "View",
            subviews: canvas.children.map({ $0.view }),
            style: self.style
            )
        case .vector( _): return View(
            name: "View", subviews: [],
            style: self.style
            )
        case .group(let group): return View(
            name: "View",
            subviews: group.children.map({ $0.view }),
            style: self.style
            )
        case .frame(let frame): return View(
            name: "View",
            subviews: frame.children.map({ $0.view }),
            style: self.style
            )
        case .text(let text): return TextView(
            text: text.characters,
            subviews: [],
            style: self.style
            )
        case .rectangle( _): return View(
            name: "View",
            subviews: [],
            style: self.style
            )
        case .component(let component): return View(
            name: component.name,
            subviews: component.children.map({ $0.view }),
            style: self.style
            )
        case .instance(let instance): return View(
            name: "View",
            subviews: instance.children.map({ $0.view }),
            style: self.style
            )
        }
    }
}

struct ViewStyle {
    enum Value {
        case number(Double)
        case string(String)
        case color(Color)
    }
    let name: String
    let properties: [String: Value]
}

extension ViewStyle.Value {
    var string: String {
        switch self {
        case .number(let number): return String(number)
        case .string(let string): return string
        case .color(let color): return "\"rgba(\(Int(255 * color.r)), \(Int(255 * color.g)), \(Int(255 * color.b)), \(color.a))\""
        }
    }
}

extension Node {
    var style: ViewStyle {
        let name = "id_" + baseNode.id.replacingOccurrences(of: ":", with: "_")
        var properties = [String: ViewStyle.Value]()
        
        if let backgroundColor = (baseNode as? ColorNode)?.backgroundColor {
            properties["color"] = .color(backgroundColor)
        }
        
        if let constraints = (baseNode as? ConstrainedNode)?.constraints {
            properties["justifyContent"] = .string(constraints.horizontal.string)
            properties["alignItems"] = .string(constraints.vertical.string)
        }
        
        if let absoluteBoundingBox = (baseNode as? BoundedNode)?.absoluteBoundingBox {
            properties["width"] = .number(absoluteBoundingBox.width)
            properties["height"] = .number(absoluteBoundingBox.height)
        }
        
        return ViewStyle(
            name: name,
            properties: properties
        )
    }
}

extension LayoutConstraint.Horizontal {
    var string: String {
        switch self {
        case .left: return "\"start\""
        case .right: return "\"end\""
        case .center: return "\"center\""
        case .leftRight: return "\"stretch\""
        case .scale: return "\"stretch\""
        }
    }
}

extension LayoutConstraint.Vertical {
    var string: String {
        switch self {
        case .top: return "\"start\""
        case .bottom: return "\"end\""
        case .center: return "\"center\""
        case .topBottom: return "\"stretch\""
        case .scale: return "\"stretch\""
        }
    }
}
