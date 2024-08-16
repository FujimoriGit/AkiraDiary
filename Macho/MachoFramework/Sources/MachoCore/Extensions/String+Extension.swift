//
//  String+Extension.swift
//
//
//  Created by 佐藤汰一 on 2024/08/07.
//

extension String {
    
    /// ファイルパスからファイル名(拡張子付き)を取得する
    func getFileNameWithExtension() -> Self? {
        
        guard let lastSubString = self.split(separator: "/").last else { return nil }
        return String(lastSubString)
    }
}
