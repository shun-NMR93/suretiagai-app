import CoreMotion
import Foundation

@MainActor
final class PedometerService: ObservableObject {
    @Published private(set) var todaySteps = 0
    @Published private(set) var isTracking = false
    @Published private(set) var statusMessage: String?

    private let pedometer = CMPedometer()

    var completedMilestones: Int {
        StepMilestone.completedCount(for: todaySteps)
    }

    var stepsUntilNextMilestone: Int {
        StepMilestone.stepsUntilNext(for: todaySteps)
    }

    var milestoneProgress: Double {
        StepMilestone.progressInCurrentBlock(for: todaySteps)
    }

    func startTracking() {
        guard CMPedometer.isStepCountingAvailable() else {
            statusMessage = "この端末では歩数計測に対応していません"
            return
        }

        let authorization = CMPedometer.authorizationStatus()
        if authorization == .denied || authorization == .restricted {
            statusMessage = "設定アプリでモーションとフィットネスの許可をオンにしてください"
            return
        }

        statusMessage = nil
        let startOfDay = Calendar.current.startOfDay(for: Date())

        pedometer.queryPedometerData(from: startOfDay, to: Date()) { [weak self] data, error in
            Task { @MainActor in
                guard let self else { return }
                if let error {
                    self.handleError(error)
                    return
                }
                if let data {
                    self.todaySteps = data.numberOfSteps.intValue
                }
            }
        }

        pedometer.startUpdates(from: startOfDay) { [weak self] data, error in
            Task { @MainActor in
                guard let self else { return }
                if let error {
                    self.handleError(error)
                    self.stopTracking()
                    return
                }
                if let data {
                    self.todaySteps = data.numberOfSteps.intValue
                    self.isTracking = true
                    self.statusMessage = nil
                }
            }
        }

        isTracking = true
    }

    func stopTracking() {
        pedometer.stopUpdates()
        isTracking = false
    }

    private func handleError(_ error: Error) {
        statusMessage = "歩数の取得に失敗しました"
        todaySteps = 0
    }
}
