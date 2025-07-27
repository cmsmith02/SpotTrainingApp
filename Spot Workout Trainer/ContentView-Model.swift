//
//  ContentView-Model.swift
//  Spot Workout Trainer
//
//  Created by Calvin Smith on 7/26/25.
//

import Foundation
import AVFoundation

extension ContentView {
    final class ViewModel: ObservableObject {
        @Published var isActive = false
        @Published var isRest = false
        @Published var workoutNum = 0
        @Published var maxNum = 0

        @Published var exerciseTime: String = "30"
        @Published var restTime: String = "10"

        @Published var exerciseSeconds: Float = 30.0
        @Published var restSeconds: Float = 10.0
        @Published var timeRemaining: Double = 30.0


        private var originalExerciseDuration: Int = 30
        private var originalRestDuration: Int = 10

        private var endDate = Date()
        private var player: AVAudioPlayer?
        
        var remainingProgress: Double {
            let total = isRest ? Double(originalRestDuration) : Double(originalExerciseDuration)
            return max(min(timeRemaining / total, 1.0), 0.0)
        }


        func updateDurations() {
            if !isActive {
                originalExerciseDuration = Int(exerciseSeconds)
                originalRestDuration = Int(restSeconds)
                exerciseTime = "\(originalExerciseDuration)"
                restTime = "\(originalRestDuration)"
            }
        }

        func start() {
            isActive = true
            let duration = isRest ? originalRestDuration : originalExerciseDuration
            endDate = Date().addingTimeInterval(TimeInterval(duration))
        }

        func toggleMode() {
            isRest.toggle()
            playSound()
            start()
        }

        func reset() {
            isActive = false
            isRest = false

            exerciseSeconds = Float(originalExerciseDuration)
            restSeconds = Float(originalRestDuration)

            exerciseTime = "\(originalExerciseDuration)"
            restTime = "\(originalRestDuration)"
        }

        func updateCountdown() {
            guard isActive else { return }

            let now = Date()
            let remaining = endDate.timeIntervalSince(now)

            if remaining <= 0 {
                isActive = false
                timeRemaining = 0

                if isRest {
                    restTime = "0"
                    restSeconds = Float(originalRestDuration)
                } else {
                    exerciseTime = "0"
                    exerciseSeconds = Float(originalExerciseDuration)
                    if workoutNum >= maxNum {
                        workoutNum = 0
                    } else {
                        workoutNum += 1
                    }
                }

                DispatchQueue.main.async {
                    self.toggleMode()
                }

                return
            }

            timeRemaining = remaining

            let displaySeconds = Int(remaining)
            if isRest {
                restTime = "\(displaySeconds)"
            } else {
                exerciseTime = "\(displaySeconds)"
            }
        }

        private func playSound() {
            guard let url = Bundle.main.url(forResource: "beep", withExtension: "mp3") else {
                print("Sound file not found.")
                return
            }

            do {
                #if os(iOS)
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                #endif
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
            } catch {
                print("Error playing sound: \(error.localizedDescription)")
            }
        }
    }
}
