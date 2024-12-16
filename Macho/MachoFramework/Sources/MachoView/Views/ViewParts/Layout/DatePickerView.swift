//
//  DatePickerView.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/12/10.
//

import SwiftUI

struct DatePickerView: View {
    
    @Binding var date: Date
    
    var body: some View {
        Text(date.toString(.init(date: .jpGregorian)))
            .font(.title3)
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
            DatePickerView(date: $date)
        }
    }
    
    return PreviewDatePickerView()
}
