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
    
    static func getToEditScreenPath(_ diary: Diary) -> Self {
        
        return .init([.editScreen(.init(editTarget: diary))])
    }
    
    static func getToGraphScreenPath() -> Self {
        
        return .init([.graphScreen(.init())])
    }
    
    static func getToDetailScreenPath(_ diary: Diary) -> Self {
        
        return .init([.detailScreen(.init(diary: diary))])
    }
}
