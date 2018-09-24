//
//  ProjectLoader.swift
//  FigmaGen
//
//  Created by Alexey Subbotkin on 23/09/2018.
//  Copyright © 2018 Alexey Subbotkin. All rights reserved.
//

import Foundation

struct ProjectLoader {
    
    let projectKey: String
    let token: String
    
    func load() throws -> Project {
        let url = URL(string: "https://api.figma.com/v1/files/\(projectKey)")!
        
        var dataRequest = URLRequest(url: url)
        dataRequest.setValue(token, forHTTPHeaderField: "X-Figma-Token")
        dataRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var project: Project!
        let semaphore = DispatchSemaphore(value: 0)
        let dataTask = URLSession.shared.dataTask(with: dataRequest) { data, response, error in
            guard let data = data else {
                return
            }
            project = try! JSONDecoder().decode(Project.self, from: data)
            semaphore.signal()
        }
        dataTask.resume()
        
        semaphore.wait()
        
        return project
    }
}
