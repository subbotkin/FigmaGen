//
//  main.swift
//  FigmaGen
//
//  Created by Alexey Subbotkin on 21/09/2018.
//  Copyright © 2018 Alexey Subbotkin. All rights reserved.
//

import Foundation
import Commander
import Darwin
import PathKit
import Stencil

let main = command(
    Argument<String>("project", description: "A Figma project key"),
    Argument<String>("token", description: "Token to access Figma"),
    Option<String>("template", default: ".", description: "Stencil template"),
    Option<String>("output_path", default: ".", description: "Where the swift files will be generated.")
) { project, token, template, outputPath in
    let projectLoader = ProjectLoader(projectKey: project, token: token)
    let project = try projectLoader.load()
    print(project)
    
    let dataToWrite = try Generator(project: project, template: Path(template)).generate()
    
    if let file = dataToWrite.first?.file, let data = dataToWrite.first?.data {
        try (Path(outputPath) + Path(file)).write(data)
    }
}

main.run("0.0.1")

