//
//  MachoFramework
//
//  NavigationRoutingExtension.swift
//
//  Created by stotic-dev on 2025/02/01
//  Copyright © Macho All rights reserved.
//

import ComposableArchitecture
import Foundation

extension StackState where Element == DiaryListFeature.Path.State {
    
    static let toCreationScreenPath: Self = .init([.createScreen(.init())])
    static let toEditScreenPath: Self = .init([.editScreen(.init(contact: .init(id: UUID(), name: "")))])
    static let toGraphScreenPath: Self = .init([.graphScreen(.init())])
    
    static func getToDetailScreenPath(_ diary: DiaryData) -> Self {
        
        return .init([.detailScreen(.init(diary: diary))])
    }
}
