//
//  OmittebleMessageView.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/11/09.
//

import SwiftUI

struct OmittableMessageView: View {
    
    // MARK: - private property
    
    // MARK: state
    
    @State private var isShowing: Bool
    
    // MARK: parameter
    
    private let text: String
    private let fontSize: CGFloat
    private let maxLength: Int
    
    // MARK: other
    
    private var maxLengthText: String {
        
        return Array(text).prefix(maxLength).map { String($0) }.joined() + Self.threePointLeader
    }
    
    // MARK: static constant
    
    private static let threePointLeader = "..."
    
    // MARK: - initialize method
    
    init(_ text: String,
         fontSize: CGFloat = 14,
         maxLength: Int = 200) {
        
        let isShowing = text.count <= maxLength
        
        self.text = text
        
        self.fontSize = fontSize
        self.maxLength = maxLength
        self.isShowing = isShowing
    }
    
    // MARK: - view build definition
    
    var body: some View {
        if isShowing {
            Text(text)
                .font(.system(size: fontSize))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        else {
            VStack(alignment: .leading) {
                ForEach(getSeparateMessageByNewLine(text: maxLengthText), id: \.self) { lineText in
                    FlowLayout(alignment: .leading, spacing: .zero) {
                        let separateChars = getSeparateChar(text: lineText)
                        ForEach(separateChars, id: \.self) {
                            Text($0)
                                .font(.system(size: fontSize))
                        }
                        if let lastString = separateChars.last,
                           lastString == Self.threePointLeader {
                            createShowMoreButton()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private extension OmittableMessageView {
    
    func createShowMoreButton() -> some View {
        Button {
            isShowing.toggle()
        } label: {
            Text("さらに表示")
                .font(.system(size: fontSize))
        }
        .frameButtonStyle(backgroundColor: .clear,
                          frameWidth: .zero)
    }
}

// MARK: - utility

private extension OmittableMessageView {
    
    func getSeparateMessageByNewLine(text: String) -> [String] {
        
        return text.components(separatedBy: "\n")
    }
    
    func getSeparateChar(text: String) -> [String] {
        
        var arrayText = Array(text).map { String($0) }
        if text.suffix(Self.threePointLeader.count) == Self.threePointLeader {
            
            // 3点リーダーが末尾にある場合は、文字の配列で分割されている
            // "."を"..."に結合させて設定する
            arrayText = arrayText.dropLast(Self.threePointLeader.count)
            arrayText.append(Self.threePointLeader)
        }
        return arrayText
    }
}

// MARK: - preview

#Preview("さらに表示") {
    VStack {
        Text("Hello")
        OmittableMessageView("lsjfljslfjsiejflsjelfiasjfsfsd"
                    + "\n"
                    // swiftlint:disable:next line_length
                    + "fsfsfsfsefsefasefasefasefsfsfefasefasefaselsaleifjlsesjeflesjlsijfseljfsifjelsjilsjfjelsijfselfijsliefjlsejjl"
                    + "\n"
                    // swiftlint:disable:next line_length
                    + "jslejfiljsefljaslejfilsjefjlasjefljsleifjlsjflaisjfleijsaeljflsiejflisjelfiajslefjlasjeflsiejflsajeflijselfjilasejfliajseljflisejflasjlefjlsejfi")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}

#Preview("省略なし") {
    VStack {
        Text("Hello")
        OmittableMessageView("lsjfljslfjsiejflsjel")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
