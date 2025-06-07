//
//  IosConnectManager.swift
//  Kartrider
//
//  Created by jiwon on 6/4/25.
//

import Foundation
import WatchConnectivity

class IosConnectManager: NSObject, WCSessionDelegate, ObservableObject {

    @Published var msg: [String: Any] = [:]

    @Published var isPlayTTS: Bool = true
    @Published var decisionIndex: Int = 0
    @Published var selectedChoice: String = ""
    @Published var decisionCount: Int = 0
    @Published var selectedOption: StoryChoiceOption? = nil

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
                let selectedChoiceRaw = message["selectedChoice"] as? String,
                let selectedChoice = StoryChoiceOption(
                    rawValue: selectedChoiceRaw),
                let decisionCount = message["decisionCount"] as? Int
            {
                self.decisionIndex = decisionIndex
                self.selectedOption = selectedChoice
                self.decisionCount = decisionCount
            }

        }
    }

    func sendStageIdle() {
        let message: [String: Any] = [
            "stage": "idle", "startContent": true,
        ]
        let session = WCSession.default
        print("[DEBUG] idle message 보내기: \(message)")

        if session.isReachable {
            print("[DEBUG] 워치로 idle 메시지 전송")
            session.sendMessage(message, replyHandler: nil)
        } else {
            print("[INFO] 세션 도달 불가. 1초 뒤 재시도.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.sendStageIdle()
            }
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

    func sendStageEndingTTS() {
        let message: [String: Any] = [
            "stage": "ending", "timerStarted": false,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendStageEndingTimer() {
        let message: [String: Any] = [
            "stage": "ending", "timerStarted": true,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }
}
