//
//  NumberFactClient.swift
//  Macho
//  
//  Created by Daiki Fujimori on 2023/10/28
//  
//

import ComposableArchitecture
import Foundation

struct NumberFactClient {
    
    var fetch: (Int) async throws -> String
}

extension NumberFactClient: DependencyKey {
    
  static let liveValue = Self(fetch: { number in
      
      guard let url = URL(string: "http://numbersapi.com/\(number)") else { return "" }
      
      let (data, _) = try await URLSession.shared.data(from: url)
      
      return String(decoding: data, as: UTF8.self)
    })
}

extension DependencyValues {
    
    var numberFact: NumberFactClient {
        
        get { self[NumberFactClient.self] }
        set { self[NumberFactClient.self] = newValue }
    }
}
