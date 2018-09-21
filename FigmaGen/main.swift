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
    Argument<String>("document", description: "A Figma document key"),
    Argument<String>("token", description: "A token to access Figma"),
    Option<String>("output_path", default: ".", description: "Where the swift files will be generated.")
) { document, token, outputPath in
    let url = URL(string: "https://api.figma.com/v1/files/\(document)")!
    
    var dataRequest = URLRequest(url: url)
    dataRequest.setValue(token, forHTTPHeaderField: "Authorization: Bearer")
    let dataTask = URLSession.shared.dataTask(with: dataRequest) { data, response, error in
        guard let data = data else {
            return
        }
        
        let string = String(data: data, encoding: .utf8)!
        Logger.log(.info, string)
    }
    dataTask.resume()

    
}

main.run("0.0.1")
