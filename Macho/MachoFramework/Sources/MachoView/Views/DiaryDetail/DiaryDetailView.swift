//
//  DiaryDetailView.swift
//  MachoFramework
//
//  Created by 佐藤汰一 on 2024/10/26.
//

import ComposableArchitecture
import RealmHelper
import SwiftUI

struct DiaryDetailView: View {
    
    @Bindable private var store: StoreOf<DiaryDetailFeature>
    
    init(store: StoreOf<DiaryDetailFeature>) {
        
        self.store = store
    }
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ZStack {
                
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    NavigationPopButton {
                        
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Detail")
        } destination: { store in
            
        }
    }
}

private extension DiaryDetailView {
    
    func createContentsArea() -> some View {
        ScrollView {
            
        }
    }
}

#Preview {
    let goal1 = TrainingGoalEntity(id: UUID(),
                                  goalType: TrainingTypeEntity(id: UUID(), name: "腹筋"), numberOfSets: 3,
                                  setCount: 3,
                                  startTime: Date(),
                                  endTime: Date(),
                                  isSuccess: true)
    let tag1 = TrainingTagEntity(id: UUID(), tagName: "XXX")
    let initialDiaryEntity = DiaryEntity(id: UUID(),
                                         date: Date(),
                                         title: "Preview",
                                         mainText: "preview sample message",
                                         goals: [goal1],
                                         tags: [tag1])
    DiaryDetailView(store: Store(initialState: DiaryDetailFeature.State(diary: initialDiaryEntity),
                                 reducer: { DiaryDetailFeature() }))
}
