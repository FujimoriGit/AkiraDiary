//
//  DiaryListFilterView.swift
//
//
//  Created by 佐藤汰一 on 2024/07/28.
//

import SwiftUI

struct DiaryListFilterView: View {
    
    // MARK: - layout property
    
    // MARK: size property
    
    private let iconSize: CGSize = .init(width: 20, height: 20)
    private let filterMenuButtonHeight: CGFloat = 30
    private let filterMenuButtonWidth: CGFloat = 120
    private let listCircleIconSize: CGSize = .init(width: 10, height: 10)
    private let filterListItemHeight: CGFloat = 35
    private let filterListMaxHeight: CGFloat = 165
    
    // MARK: font property
    
    private let dialogTitleFontSize: CGFloat = 18
    private let filterListItemTitleFontSize: CGFloat = 16
    private let filterMenuButtonFontSize: CGFloat = 16
    
    // MARK: padding property
    
    private let dialogTitlePaddingBottom: CGFloat = 24
    private let filterSectionPaddingBottom: CGFloat = 24
    private let dialogPadding: CGFloat = 16
    private let filterListItemPaddingLeading: CGFloat = 20
    private let listCircleIconPaddingTrailing: CGFloat = 8
    
    // MARK: radius property
    
    private let dialogCornerRadius: CGFloat = 8
    
    
    // MARK: - view body property
        
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                Color(asset: CustomColor.dialogBackgroundColor)
                    .ignoresSafeArea()
                    .onTapGesture {
                        print("on tap background area.")
                    }
                createDialogView(parentSize: proxy.size)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// MARK: - private method

private extension DiaryListFilterView {
    
    func createDialogView(parentSize: CGSize) -> some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: .zero) {
                Text("日記リストのフィルター設定")
                    .font(.system(size: dialogTitleFontSize,
                                  weight: .bold))
                Spacer()
                    .frame(height: dialogTitlePaddingBottom)
                ForEach(DiaryListFilterTarget.allCases,
                        id: \.hashValue) { target in
                    switch target {
                        
                    case .achievement:
                        createSelectOnlyItemSectionWithMenu(target: target)
                        
                    case .trainingType:
                        createSelectMultiItemSectionWithMenu(target: target)
                    }
                    Spacer()
                        .frame(height: filterSectionPaddingBottom)
                }
                .padding(.horizontal, dialogPadding)
            }
            .padding(.vertical, dialogPadding)
            .frame(width: parentSize.width - dialogPadding)
            .background(Color(asset: CustomColor.appPrimaryBackgroundColor))
            .borderModifier(cornerRadius: dialogCornerRadius)
            Button(action: {
                print("tap close dialog.")
            }, label: {
                Image(systemName: "xmark.circle")
                    .resizable()
                    .frame(width: iconSize.width, height: iconSize.height)
            })
            .frameButtonStyle(frameWidth: .zero, cornerRadius: iconSize.width / 2)
            .padding(dialogPadding)
        }
    }
    
    func createSelectOnlyItemSectionWithMenu(target: DiaryListFilterTarget) -> some View {
        HStack(spacing: .zero) {
            createSelectMenu(target)
            Spacer()
                .frame(width: 8)
            Text("目標達成した")
            Spacer()
            createClearFilterTargetButton(target)
        }
    }
    
    func createSelectMultiItemSectionWithMenu(target: DiaryListFilterTarget) -> some View {
        VStack(spacing: .zero) {
            HStack(spacing: .zero) {
                createSelectMenu(target)
                Spacer()
                createClearFilterTargetButton(target)
            }
            Spacer()
                .frame(height: filterSectionPaddingBottom)
            ScrollView {
                VStack(spacing: .zero) {
                    HStack(spacing: .zero) {
                        Spacer()
                            .frame(width: filterListItemPaddingLeading)
                        Circle()
                            .frame(width: listCircleIconSize.width,
                                   height: listCircleIconSize.height)
                            .padding(.trailing, listCircleIconPaddingTrailing)
                        Text("腹筋")
                            .font(.system(size: filterListItemTitleFontSize))
                        Spacer()
                        createClearFilterTargetButton(target, selectCase: "")
                    }
                }
            }
            .frame(maxHeight: filterListMaxHeight)
            .scrollBounceBehavior(.basedOnSize)
        }
    }
    
    func createSelectMenu(_ target: DiaryListFilterTarget) -> some View {
        Menu {
            ForEach(target.selectableCases, id: \.self) { selectCase in
                Button(action: {
                    print("tap Title menu(target: \(target), select: \(selectCase)).")
                }, label: {
                    Text(selectCase)
                })
            }
        } label: {
            Text(target.title)
                .font(.system(size: filterMenuButtonFontSize))
                .frame(width: filterMenuButtonWidth, height: filterMenuButtonHeight)
        }
        .frameButtonStyle()
    }
    
    func createClearFilterTargetButton(_ target: DiaryListFilterTarget, selectCase: String? = nil) -> some View {
        Button(action: {
            
        }, label: {
            Image(systemName: "minus.circle.fill")
                .resizable()
                .frame(width: iconSize.width,
                       height: iconSize.height)
                .foregroundStyle(Color(asset: CustomColor.deleteSwipeBackgroundColor))
        })
    }
}

// MARK: - preview section

#Preview {
    DiaryListFilterView()
}
