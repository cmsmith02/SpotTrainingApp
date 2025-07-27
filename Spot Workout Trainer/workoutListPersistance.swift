//
//  workoutListPersistance.swift
//  Spot Workout Trainer
//
//  Created by Calvin Smith on 7/26/25.
//

import Foundation
extension UserDefaults {
    private static let workoutsKey = "savedWorkouts"

    func saveWorkouts(_ workouts: [String]) {
        let data = try? JSONEncoder().encode(workouts)
        set(data, forKey: Self.workoutsKey)
    }

    func loadWorkouts() -> [String] {
        guard let data = data(forKey: Self.workoutsKey),
              let workouts = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }

        return workouts
    }
}
