//
//  WatchConnectManager.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/4/25.
//

import Foundation
import WatchConnectivity

class WatchConnectManager: NSObject, WCSessionDelegate, ObservableObject {

    var session: WCSession

    @Published var message: [String: Any] = [:]
    @Published var currentStage: String = ""
    @Published var hasStartedContent: Bool = false
    @Published var isTimerRunning: Bool = false
    @Published var isTTSPlaying: Bool = true
    @Published var decisionIndex: Int = 0
    @Published var isFirstRequest: Bool = false
    @Published var isInterrupted: Bool = false

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        if WCSession.isSupported() {
            self.session.delegate = self
            self.session.activate()
        } else {
            print("[ERROR] WCSession not supported")
        }
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        print("Session activated: \(activationState.rawValue)")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any])
    {
        DispatchQueue.main.async {
            print("[DEBUG] Received message: \(message)")
            guard let currentStage = message["stage"] as? String else {
                print("[ERROR] stage is nil")
                return
            }
            print(
                "[DEBUG] stage raw value: '\(currentStage)' (type: \(type(of: currentStage)))"
            )

            if let hasStartedContent = message["startContent"] as? Bool {
                self.hasStartedContent = hasStartedContent
            }
            if let isTimerRunning = message["timerStarted"] as? Bool {
                self.isTimerRunning = isTimerRunning
            }
            if let isTTSPlaying = message["isPlayTTS"] as? Bool {
                self.isTTSPlaying = isTTSPlaying
            }
            if let decisionIndex = message["decisionIndex"] as? Int {
                self.decisionIndex = decisionIndex
            }
            if let isFirstRequest = message["isFirstRequest"] as? Bool {
                self.isFirstRequest = isFirstRequest
            }
            if let isInterrupted = message["isInterrupt"] as? Bool {
                self.isInterrupted = isInterrupted
            }

            print("[STAGE] stage: \(currentStage)")

            self.currentStage = currentStage
            print("[DEBUG] stage did change to '\(self.currentStage)'")

            switch currentStage {
            case "idle":
                print("[IDLE] startContent: \(self.hasStartedContent)")
                self.message = [
                    "stage": "idle", "startContent": self.hasStartedContent,
                ]
            case "exposition":
                print("[EXPOSITION] isPlayTTS: \(self.isTTSPlaying)")
                self.message = [
                    "stage": "exposition", "isPlayTTS": self.isTTSPlaying,
                ]
            case "decision":
                print(
                    "[DECISION] timerStarted: \(self.isTimerRunning), decisionIndex: \(self.decisionIndex), isFirstRequest: \(self.isFirstRequest)"
                )
                self.message = [
                    "stage": "decision", "timerStarted": self.isTimerRunning,
                    "decisionIndex": self.decisionIndex,
                    "isFirstRequest": self.isFirstRequest,
                ]
            case "ending":
                print("[ENDING] timerStarted: \(self.isTimerRunning)")
                self.message = [
                    "stage": "ending", "timerStarted": self.isTimerRunning,
                ]
            default:
                print("[ERROR] wrong stage: \(currentStage)")
            }
        }
    }

    func sendStageExpositionWithPause() {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(["isPlayTTS": false], replyHandler: nil)
        }
    }

    func sendStageExpositionWithResume() {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(["isPlayTTS": true], replyHandler: nil)
        }
    }

    func sendFirstChoiceToIos(_ decisionIndex: Int, _ selectedChoice: String) {
        let message: [String: Any] = [
            "decisionIndex": decisionIndex, "selectedChoice": selectedChoice,
            "decisionCount": 1,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendSecChoiceToIos(_ decisionIndex: Int, _ selectedChoice: String) {
        let message: [String: Any] = [
            "decisionIndex": decisionIndex, "selectedChoice": selectedChoice,
            "decisionCount": 2,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendTimeoutToIos(_ decisionIndex: Int, isFirstRequest: Bool) {
        let message: [String: Any] = [
            "decisionIndex": decisionIndex,
            "timeout": true,
            "isFirstRequest": isFirstRequest,
        ]
        guard session.isReachable else { return }
        session.sendMessage(message, replyHandler: nil)
    }

    func sendFirstTimeout(_ decisionIndex: Int) {
        sendTimeoutToIos(decisionIndex, isFirstRequest: true)
    }

    func sendSecondTimeout(_ decisionIndex: Int) {
        sendTimeoutToIos(decisionIndex, isFirstRequest: false)
    }
}
