//
//  DiaryListFilterView.swift
//
//
//  Created by 佐藤汰一 on 2024/07/28.
//

import Combine
import ComposableArchitecture
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
    
    // MARK: private property
    
    private let store: StoreOf<DiaryListFilterFeature>
    
    // MARK: initialize method
    
    init(store: StoreOf<DiaryListFilterFeature>) {
        
        self.store = store
    }
    
    // MARK: - view body property
    
    var body: some View {
        WithViewStore(store, observe: \.currentFilters) { viewStore in
            ZStack {
                GeometryReader { proxy in
                    Color(asset: CustomColor.dialogBackgroundColor)
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewStore.send(.tappedOutsideArea)
                        }
                    createDialogView(viewStore, parentSize: proxy.size)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

// MARK: - private method

private extension DiaryListFilterView {
    
    func createDialogView(_ viewStore: ViewStore<IdentifiedArrayOf<DiaryListFilterItem>, DiaryListFilterFeature.Action>,
                          parentSize: CGSize) -> some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: .zero) { // ダイアログエリア
                Text("日記リストのフィルター設定")
                    .font(.system(size: dialogTitleFontSize,
                                  weight: .bold))
                Spacer()
                    .frame(height: dialogTitlePaddingBottom)
                ScrollView {
                    VStack(spacing: .zero) {
                        ForEach(DiaryListFilterTarget.allCases,
                                id: \.hashValue) { target in
                            switch target {
                                
                            case .achievement:
                                createSelectOnlyItemSectionWithMenu(viewStore, target: target)
                                
                            case .trainingType:
                                createSelectMultiItemSectionWithMenu(viewStore, target: target)
                            }
                            Spacer()
                                .frame(height: filterSectionPaddingBottom)
                        }
                        .padding(.horizontal, dialogPadding)
                    }
                }
                .frame(maxHeight: filterListMaxHeight)
                .scrollBounceBehavior(.basedOnSize)
            }
            .padding(.vertical, dialogPadding)
            .frame(width: parentSize.width - dialogPadding)
            .background(Color(asset: CustomColor.appPrimaryBackgroundColor))
            .borderModifier(cornerRadius: dialogCornerRadius)
            Button(action: { // 閉じるボタン
                viewStore.send(.tappedCloseButton)
            }, label: {
                Image(systemName: "xmark.circle")
                    .resizable()
                    .frame(width: iconSize.width, height: iconSize.height)
            })
            .frameButtonStyle(frameWidth: .zero,
                              cornerRadius: iconSize.width / 2)
            .padding(dialogPadding)
        }
    }
    
    func createSelectOnlyItemSectionWithMenu(_ viewStore: ViewStore<IdentifiedArrayOf<DiaryListFilterItem>, DiaryListFilterFeature.Action>,
                                             target: DiaryListFilterTarget) -> some View {
        HStack(spacing: .zero) {
            createSelectMenu(viewStore, target: target)
            Spacer()
                .frame(width: 8)
            Text(viewStore.state.first { $0.target == target }?.value ?? "-")
            Spacer()
            createClearFilterTargetButton(viewStore, target: target)
        }
    }
    
    func createSelectMultiItemSectionWithMenu(_ viewStore: ViewStore<IdentifiedArrayOf<DiaryListFilterItem>, DiaryListFilterFeature.Action>,
                                              target: DiaryListFilterTarget) -> some View {
        VStack(spacing: .zero) {
            HStack(spacing: .zero) {
                createSelectMenu(viewStore, target: target)
                Spacer()
                createClearFilterTargetButton(viewStore, target: target)
            }
            Spacer()
                .frame(height: filterSectionPaddingBottom)
            // TODO: トレーニング種別のフィルター表示どうやって全件表示するか要検討
            ForEach(viewStore.state.filter { $0.target == target }) { filter in
                HStack(spacing: .zero) {
                    Spacer()
                        .frame(width: filterListItemPaddingLeading)
                    Circle()
                        .frame(width: listCircleIconSize.width,
                               height: listCircleIconSize.height)
                        .padding(.trailing, listCircleIconPaddingTrailing)
                    Text(filter.value)
                        .font(.system(size: filterListItemTitleFontSize))
                    Spacer()
                    createClearFilterTargetButton(viewStore, target: target, selectCase: "")
                }
            }
        }
    }
    
    func createSelectMenu(_ viewStore: ViewStore<IdentifiedArrayOf<DiaryListFilterItem>, DiaryListFilterFeature.Action>,
                          target: DiaryListFilterTarget) -> some View {
        Menu {
            ForEach(target.selectableCases, id: \.self) { selectCase in
                Button(action: {
                    viewStore.send(.tappedFilterMenuItem(target: target, value: selectCase))
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
    
    func createClearFilterTargetButton(_ viewStore: ViewStore<IdentifiedArrayOf<DiaryListFilterItem>, DiaryListFilterFeature.Action>,
                                       target: DiaryListFilterTarget,
                                       selectCase: String? = nil) -> some View {
        Button(action: {
            guard let selectCase else {
                viewStore.send(.tappedFilterTypeDeleteButton(target: target))
                return
            }
            viewStore.send(.tappedFilterItemDeleteButton(target: target, value: selectCase))
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
    let publisher = PassthroughSubject<[DiaryListFilterItem], Never>()
    var currentFilters = [DiaryListFilterItem(id: UUID(), target: .achievement, value: "達成していない"),
                          DiaryListFilterItem(id: UUID(), target: .trainingType, value: "腹筋")]
    return DiaryListFilterView(store: Store(initialState: DiaryListFilterFeature.State(),
                                     reducer: { DiaryListFilterFeature() },
                                     withDependencies: {
        $0.diaryListFilterApi = DiaryListFilterClient(addFilter: { filter in
            
            currentFilters = currentFilters + [filter]
            publisher.send(currentFilters)
            return true
        }, updateFilter: { filter in
            
            guard let index = currentFilters.firstIndex(where: { $0.target == filter.target }) else { return false }
            currentFilters[index] = filter
            publisher.send(currentFilters)
            return true
        }, deleteFilters: { targets in
            
            currentFilters = currentFilters.filter { !targets.contains($0) }
            publisher.send(currentFilters)
            return true
        }, fetchFilterList: {
            
            return currentFilters
        }, getFilterListObserver: {
            
            return publisher.eraseToAnyPublisher()
        })
    }))
}
