//
//  DatePickerView.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/12/10.
//

import SwiftUI

struct DatePickerView: View {
    
    @Binding var date: Date
    private let titleFont: Font
    
    init(date: Binding<Date>,
         titleFont: Font) {
        
        _date = date
        self.titleFont = titleFont
    }
    
    var body: some View {
        Text(date.formatted(.localDate))
            .font(titleFont)
            .foregroundStyle(Color(asset: CustomColor.appPrimaryTextColor))
            .overlay {
                DatePicker(
                    "日時選択メニュー",
                    selection: $date,
                    displayedComponents: [.date]
                )
                .labelsHidden()
                .blendMode(.destinationOver)
            }
    }
}

#Preview {
    
    struct PreviewDatePickerView: View {
        
        @State private var date = Date()
        
        var body: some View {
            DatePickerView(date: $date,
                           titleFont: .macho(.subTitle))
        }
    }
    
    return PreviewDatePickerView()
}
