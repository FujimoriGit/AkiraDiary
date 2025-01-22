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
            HStack(spacing: .zero) {
                createTitle()
                    .frame(maxWidth: .infinity,
                           alignment: .leading)
                Button {
                    store.send(.tappedCloseButton)
                } label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .padding(8)
                }
                .frameButtonStyle(frameWidth: .zero)
            }
            Spacer()
                .frame(maxHeight: 24)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(store.activities, id: \.id) {
                    createActivityButton($0)
                }
            }
            .padding(.leading, 16)
        }
    }
}

// MARK: - private method

private extension DetailDayOfActivityView {
    
    func createTitle() -> some View {
        Label {
            Text("アクティビティの詳細(\(store.targetDayStr))")
                .multilineTextAlignment(.leading)
        } icon: {
            createAchievedIcon(store.isAchieved)
        }
    }
    
    func createActivityButton(_ activity: ActivityResultOfDay.ActivityEvent) -> some View {
        Button {
            store.send(.delegate(.tappedActivityArea(diaryId: activity.id)))
        } label: {
            HStack(spacing: 16) {
                createAchievedIcon(activity.isAchieved)
                Text(activity.title)
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
        targetDate: .now,
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
            }
        )
    )
}
