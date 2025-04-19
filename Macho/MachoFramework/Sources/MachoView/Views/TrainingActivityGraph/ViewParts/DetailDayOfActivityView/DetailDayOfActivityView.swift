//
//  MachoFramework
//
//  DetailDayOfActivityView.swift
//
//  Created by stotic-dev on 2025/01/21
//  Copyright © Macho All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct DetailDayOfActivityView: PopUpableContentView {
    
    typealias Feature = DetailDayOfActivityFeature
    
    // MARK: - private property
    
    // MARK: store property
    
    @Bindable private var store: StoreOf<Feature>
    
    // MARK: - initialize method
    
    init(store: some StoreOf<Feature>) {
        
        self.store = store
    }
    
    // MARK: - view definition
    
    var body: some View {
        VStack(spacing: .zero) {
            HStack(alignment: .top, spacing: .zero) {
                createTitle()
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity,
                           alignment: .leading)
                PopUpCloseButton {
                    store.send(.tappedCloseButton)
                }
            }
            Spacer()
                .frame(maxHeight: .space(.large))
            VStack(alignment: .leading,
                   spacing: .space(.small)) {
                ForEach(store.activities, id: \.id) {
                    createActivityButton($0)
                }
            }
                   .padding(.leading, .space(.medium))
        }
    }
}

// MARK: - private method

private extension DetailDayOfActivityView {
    
    func createTitle() -> some View {
        Label {
            Text("詳細(\(store.targetDayStr))")
                .font(.macho(.subTitle))
                .multilineTextAlignment(.leading)
        } icon: {
            createAchievedIcon(store.isAchieved)
        }
    }
    
    func createActivityButton(_ activity: ActivityResultOfDay.ActivityEvent) -> some View {
        Button {
            store.send(.delegate(.tappedActivityArea(diaryId: activity.id)))
        } label: {
            HStack(spacing: .space(.medium)) {
                createAchievedIcon(activity.isAchieved)
                Text(activity.title)
                    .font(.macho(.description))
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    func createAchievedIcon(_ isAchieved: Bool) -> some View {
        Image(systemName: isAchieved ? "checkmark" : "xmark")
            .foregroundStyle(Color.getWinOrLoseColorByIsAchieved(isAchieved))
    }
}

// MARK: - preview definition

#Preview {
    let result = ActivityResultOfDay(
        targetDate: .init(year: 2025, month: 1, day: 1),
        activities: [
            .init(id: UUID(), title: "Test1", isAchieved: true),
            .init(id: UUID(), title: "Test2", isAchieved: false)
        ]
    )
    
    PopUpView<DetailDayOfActivityView, DetailDayOfActivityFeature>(
        store: Store(
            initialState: .init(
                childState: .init(result)
            ),
            reducer: {
                
                PopUpFeature<DetailDayOfActivityFeature>()
            }, withDependencies: {
                
                $0.dismiss = .init({})
            }
        )
    )
}
