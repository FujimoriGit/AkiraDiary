//
//  MachoFramework
//
//  MachoShaderLibrary.swift
//
//  Created by stotic-dev on 2025/05/24
//  Copyright © Macho All rights reserved.
//

import SwiftUI

extension Bundle {
    
    static let machoView: Bundle = .module
}

extension ShaderLibrary {
    
    static let machoViewLib: ShaderLibrary = .bundle(.machoView)
}
