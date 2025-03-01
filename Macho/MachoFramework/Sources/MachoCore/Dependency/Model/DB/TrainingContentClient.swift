struct TrainingContentClient {

    /// 目標の登録
    var addGoals: ([Goal]) async -> Bool
    /// 目標の更新
    var updateGoal: (Goal) async -> Bool
    /// 登録している目標をすべて取得する
    var fetchAll: () async -> [TrainingContentData]
    /// 監視用のPublisherを返す
    var getTrainingGoalPublisher: () -> AnyPublisher<[TrainingContentData], Never>
}