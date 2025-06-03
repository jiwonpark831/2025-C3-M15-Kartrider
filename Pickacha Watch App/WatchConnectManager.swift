//
//  WatchConnectManager.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/4/25.
//

import Foundation
import WatchConnectivity

class WatchConnectManager: NSObject, WCSessionDelegate, ObservableObject {
    @Published var stage: String = ""
    @Published var timerStarted: Bool = false
    @Published var ttsStatus: String = ""
    @Published var decisionIndex: Int = 0
    @Published var selectedChoice: String = ""
    @Published var isFirstRequest: Bool = false
    @Published var decisionCount: Int = 0
    @Published var isInterrupt: Bool = false

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
    func session(_ session: WCSession, didReceiveMessage message: [String: Any])
    {
        DispatchQueue.main.async {
            if let newStage = message["stage"] as? String {
                self.stage = newStage
            }
            if let newTimerStarted = message["timerStarted"] as? Bool {
                self.timerStarted = newTimerStarted
            }
            if let newTtsStatus = message["ttsStatus"] as? String {
                self.ttsStatus = newTtsStatus
            }
            if let newDecisionIndex = message["decisionIndex"] as? Int {
                self.decisionIndex = newDecisionIndex
            }
            if let newSelectedChoice = message["selectedChoice"] as? String {
                self.selectedChoice = newSelectedChoice
            }
            if let newIsFirstRequest = message["isFirstRequest"] as? Bool {
                self.isFirstRequest = newIsFirstRequest
            }
            if let newIsInterrupt = message["isInterrupt"] as? Bool {
                self.isInterrupt = newIsInterrupt
            }

        }
    }

    func sendTtsStatus(_ ttsStatus: String) {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(["ttsStatus": ttsStatus], replyHandler: nil)
        }
    }

    func sendSelectedChoice(_ selectedChoice: String) {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(
                ["selectedChoice": selectedChoice], replyHandler: nil)
        }
    }

    func sendDecisionCount(_ decisionCount: Int) {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(
                ["decisionCount": decisionCount], replyHandler: nil)
        }
    }

}
