//
//  TrainingTagData.swift
//  Macho
//
//  Created by 佐藤汰一 on 2023/11/04.
//

import Foundation

public protocol TrainingTagData: Equatable, Sendable, Identifiable {
    
    var id: UUID { get }
    var tagName: String { get }
}
