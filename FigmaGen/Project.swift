//
//  Project.swift
//  FigmaGen
//
//  Created by Alexey Subbotkin on 23/09/2018.
//  Copyright © 2018 Alexey Subbotkin. All rights reserved.
//

import Foundation

final class Project: NSObject, Decodable {
    let name: String
    let version: String
    let document: Document
    
    override init() {
        fatalError()
    }
}

extension Project {
    var components: [ComponentNode] {
        let allNodes = document.node.allNodes
        return allNodes.compactMap({ $0.component })
    }
}
