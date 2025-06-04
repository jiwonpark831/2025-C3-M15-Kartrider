//
//  IosConnectManager.swift
//  Kartrider
//
//  Created by jiwon on 6/4/25.
//

import Foundation
import WatchConnectivity

class IosConnectManager: NSObject, WCSessionDelegate, ObservableObject {

    @Published var isPlayTTS: Bool = true
    @Published var decisionIndex: Int = 0
    @Published var selectedChoice: String = ""
    @Published var decisionCount: Int = 0

    var session: WCSession

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {

    }

    func sessionDidBecomeInactive(_ session: WCSession) {

    }

    func sessionDidDeactivate(_ session: WCSession) {

    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any])
    {
        DispatchQueue.main.async {
            if let isPlayTTS = message["isPlayTTS"] as? Bool {
                self.isPlayTTS = isPlayTTS
            }

            if let decisionIndex = message["decisionIndex"] as? Int,
                let selectedChoice = message["selectedChoice"] as? String,
                let decisionCount = message["decisionCount"] as? Int
            {
                self.decisionIndex = decisionIndex
                self.selectedChoice = selectedChoice
                self.decisionCount = decisionCount
            }

        }
    }

    func sendStageIdle() {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(["stage": "idle"], replyHandler: nil)
        }
    }

    func sendStageExpositionWithPause() {
        let message: [String: Any] = [
            "stage": "exposition", "isPlayTTS": false,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendStageExpositionWithResume() {
        let message: [String: Any] = [
            "stage": "exposition", "isPlayTTS": true,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendStageDecisionWithFirstTTS(_ decisionIndex: Int) {
        let message: [String: Any] = [
            "stage": "decision", "timerStarted": false,
            "decisionIndex": decisionIndex, "isFirstRequest": true,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendStageDecisionWithFirstTimer(_ decisionIndex: Int) {
        let message: [String: Any] = [
            "stage": "decision", "timerStarted": true,
            "decisionIndex": decisionIndex, "isFirstRequest": true,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendStageDecisionWithSecTTS(_ decisionIndex: Int) {
        let message: [String: Any] = [
            "stage": "decision", "timerStarted": false,
            "decisionIndex": decisionIndex, "isFirstRequest": false,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendStageDecisionWithSecTimer(_ decisionIndex: Int) {
        let message: [String: Any] = [
            "stage": "decision", "timerStarted": true,
            "decisionIndex": decisionIndex, "isFirstRequest": false,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendChoiceInterrupt() {
        let message: [String: Any] = [
            "stage": "decision", "isInterrupt": true,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendStageEnding() {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(["stage": "ending"], replyHandler: nil)
        }
    }
}
