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
    
    static func getToCreationScreenPath() -> Self {
        
        return .init([.createScreen(.init())])
    }
    
    static func getToEditScreenPath() -> Self {
        
        return .init([.editScreen(.init(contact: .init(id: UUID(), name: "")))])
    }
    
    static func getToGraphScreenPath() -> Self {
        
        return .init([.graphScreen(.init())])
    }
    
    static func getToDetailScreenPath(_ diary: DiaryData) -> Self {
        
        return .init([.detailScreen(.init(diary: diary))])
    }
}
