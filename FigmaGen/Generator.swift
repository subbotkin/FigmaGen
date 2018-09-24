//
//  Generator.swift
//  FigmaGen
//
//  Created by Alexey Subbotkin on 23/09/2018.
//  Copyright © 2018 Alexey Subbotkin. All rights reserved.
//

import Foundation
import Stencil
import StencilSwiftKit
import PathKit

final class Generator {
    
    private let project: Project
    
    private let templatePath: Path
    
    init(project: Project, template path: Path? = nil) throws {
        self.project = project
        templatePath = path ?? Path.current + Path("Templates/ReactNative.stencil")
    }
    
    func generate() throws -> [(file: String, data: String?)] {
        let templateString: String = try templatePath.read()
        let environment = stencilSwiftEnvironment()
        
        let templateClass = StencilSwiftTemplate(templateString: templateString,
                                                 environment: environment,
                                                 name: nil)
        
        let context: [String: Any] = ["component": Node.component(project.components.first!).view]
        let string = try! templateClass.render(context)
        
        return [(file: "Output.js", data: string)]
    }
}
