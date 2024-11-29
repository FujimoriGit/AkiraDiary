//
//  TrainingTypeData.swift
//
//  
//  Created by Daiki Fujimori on 2024/08/16
//  

import Foundation

public protocol TrainingTypeData: Equatable, Sendable, Identifiable {
    
    var id: UUID { get }
    var name: String { get }
}
