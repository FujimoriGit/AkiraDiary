//
//  MachoFramework
//
//  DiaryStatus.swift
//
//  Created by stotic-dev on 2025/03/20
//  Copyright © Macho All rights reserved.
//

import CasePaths
import Foundation

@CasePathable
enum DiaryStatus: Equatable {
    
    case training
    case finished(DiaryFinishInfo)
    
    var isFinished: Bool { self.is(\.finished) }
}
