//
//  MachoFramework
//
//  DependenciesInject.swift
//
//  Created by stotic-dev on 2025/05/17
//  Copyright © Macho All rights reserved.
//

import Dependencies
import MachoLocalStorage
import MachoCore

extension DiaryEntityClient: DependencyKey {
    
    public static let liveValue: DiaryEntityClient = .concreteValue
}

extension DiaryListFilterClient: DependencyKey {
    
    public static let liveValue: DiaryListFilterClient = .concreteValue
}

extension TrainingContentClient: DependencyKey {
    
    public static let liveValue: TrainingContentClient = .concreteValue
}

extension TrainingTagClient: DependencyKey {
    
    public static let liveValue: TrainingTagClient = .concreteValue
}

extension TrainingTypeClient: DependencyKey {
    
    public static let liveValue: TrainingTypeClient = .concreteValue
}
