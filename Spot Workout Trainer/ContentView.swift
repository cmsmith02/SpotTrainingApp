//
//  ContentView.swift
//  Spot Workout Trainer
//
//  Created by Calvin Smith on 7/26/25.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var vm = ViewModel()
    @State private var showingAdder = false
    @State private var showingRemover = false
    @State private var exerciseInput: String = ""
    @State private var showingList = false
    @State private var workouts: [String] = UserDefaults.standard.loadWorkouts()
    @State private var inSession = false
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    private let width: Double = 250

    var body: some View {
        if inSession {
            sessionView
        }
        else {
            setupView
        }
    }
    var setupView: some View {
        VStack(spacing: 20) {
            Text("Exercise Duration:")
                .font(.title)
                .bold()
            Text("\(vm.exerciseTime)")
                .font(.system(size: 70, weight: .medium, design: .rounded))
                .padding()
                .frame(width: width)
                .background(.thinMaterial)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 4))
            Text("Rest Duration:")
                .font(.title)
                .bold()
            Text("\(vm.restTime)")
                .font(.system(size: 70, weight: .medium, design: .rounded))
                .padding()
                .frame(width: width)
                .background(.thinMaterial)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 4))
            
            VStack {
                Text("Set Exercise Duration:")
                Slider(value: $vm.exerciseSeconds, in: 1...60)
                    .padding()
                    .frame(width: width)
                    .disabled(vm.isActive)
                    .onChange(of: vm.exerciseSeconds) { _ in
                        vm.updateDurations()
                    }
                
                Text("Set Rest Duration:")
                Slider(value: $vm.restSeconds, in: 1...60)
                    .padding()
                    .frame(width: width)
                    .disabled(vm.isActive)
                    .onChange(of: vm.restSeconds) { _ in
                        vm.updateDurations()
                    }
            }
            
            HStack(spacing: 50) {
                Button("Start") {
                    vm.isRest = false
                    vm.maxNum = workouts.count - 1
                    vm.start()
                    inSession = true
                }
                .disabled(vm.isActive)
                
            }
            .frame(width: width)
            VStack {
                Button("Show Exercises") {
                    showingList.toggle()
                }
            }
            .sheet(isPresented: $showingList) {
                VStack(spacing: 20) {
                    
                    if workouts.isEmpty {
                        Text("No exercises added yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(workouts, id: \.self) { workout in
                            Text(workout)
                        }
                    }
                    
                    Button("Close") {
                        showingList = false
                    }
                }
                .padding()
            }
            
            VStack {
                Button("Add Exercise") {
                    showingAdder.toggle()
                }
            }
            .sheet(isPresented: $showingAdder) {
                VStack(spacing: 20) {
                    Text("Enter Exercise")
                        .font(.headline)
                    TextField("Ex: Pushups", text: $exerciseInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    HStack {
                        Button("Submit") {
                            if !exerciseInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                workouts.append(exerciseInput)
                                UserDefaults.standard.saveWorkouts(workouts)
                                showingAdder = false
                            }
                        }
                        Button("Cancel") {
                            showingAdder = false
                        }
                    }
                }
                .padding()
            }
            VStack{
                Button("Remove Exercise") {
                    showingRemover.toggle()
                }
            }
            .sheet(isPresented: $showingRemover) {
                VStack(spacing: 20) {
                    Text("Enter Exercise to Remove")
                        .font(.headline)
                    TextField("Ex: Pushups", text: $exerciseInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    HStack {
                        Button("Submit") {
                            let trimmed = exerciseInput.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty {
                                workouts.removeAll(where: { $0 == trimmed })
                                UserDefaults.standard.saveWorkouts(workouts)
                                exerciseInput = ""
                                showingRemover = false
                            }
                        }
                        Button("Cancel") {
                            exerciseInput = ""
                            showingRemover = false
                        }
                    }
                }
                .padding()
            }
            
        }
        .onReceive(timer) { _ in
            vm.updateCountdown()
        }
    }
    var sessionView: some View {
        VStack(spacing: 20) {
            Text(vm.isRest ? "Rest" : "Exercise")
                .font(.largeTitle)
                .foregroundColor(vm.isRest ? .blue : .green)
                .bold()

            if workouts.indices.contains(vm.workoutNum) {
                Text(vm.isRest ? "Next exercise is: \(workouts[vm.workoutNum])" : "Exercise is: \(workouts[vm.workoutNum])")
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
            }

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 12)

                Circle()
                    .trim(from: 0, to: CGFloat(vm.remainingProgress))
                    .stroke(
                        AngularGradient(gradient: Gradient(colors: [.white, .white.opacity(0.5)]), center: .center),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: vm.remainingProgress)

                Text("\(vm.isRest ? vm.restTime : vm.exerciseTime)")
                    .font(.system(size: 80, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(width: 250, height: 250)
            .padding(.horizontal)


            Button("Exit Session") {
                vm.reset()
                inSession = false // Go back to setup
            }
            .foregroundColor(.red)
            .padding()
        }
        .onReceive(timer) { _ in
            vm.updateCountdown()
        }
    }
}
