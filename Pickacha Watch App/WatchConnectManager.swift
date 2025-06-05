//
//  WatchConnectManager.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/4/25.
//

import Foundation
import WatchConnectivity

class WatchConnectManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchConnectManager()

    //    weak var watchStartVM: WatchStartViewModel?
    //    weak var watchStoryVM: WatchStoryViewModel?
    //    weak var watchExpositionVM: ExpositionViewModel?
    //    weak var watchDecisionVM: DecisionViewModel?
    //    weak var watchOutroVM: WatchOutroViewModel?
    var watchStartVM = WatchStartViewModel()
    var watchStoryVM = WatchStoryViewModel()
    var watchExpositionVM = ExpositionViewModel()
    var watchDecisionVM = DecisionViewModel()
    var watchOutroVM = WatchOutroViewModel()

    @Published var stage: String = ""
    @Published var startContent: Bool = false
    @Published var timerStarted: Bool = false
    @Published var isPlayTTS: Bool = true
    @Published var decisionIndex: Int = 0
    @Published var isFirstRequest: Bool = false
    @Published var isInterrupt: Bool = false

    var session: WCSession

    private init(session: WCSession = .default) {
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
        print("Session activated: \(activationState.rawValue)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            print("Received message: \(message)")

            guard let stage = message["stage"] as? String else {
                print("error - stage is nil or not String")
                return
            }

            // 필요한 값 파싱
            if let timerStartedInt = message["timerStarted"] as? Int {
                self.timerStarted = timerStartedInt != 0
            }
            if let isPlayTTS = message["isPlayTTS"] as? Bool {
                self.isPlayTTS = isPlayTTS
            }
            if let decisionIndex = message["decisionIndex"] as? Int {
                self.decisionIndex = decisionIndex
            }
            if let isFirstRequestInt = message["isFirstRequest"] as? Int {
                self.isFirstRequest = isFirstRequestInt != 0
            }
            if let isInterruptInt = message["isInterrupt"] as? Int {
                self.isInterrupt = isInterruptInt != 0
            }

            print("Parsed values — stage: \(stage), isFirstRequest: \(self.isFirstRequest), timerStarted: \(self.timerStarted)")

            // String 값으로 조건 처리
            switch stage.lowercased() {
            case "idle":
                self.watchStartVM.isStart = self.startContent
            case "exposition":
                self.watchStoryVM.storyNodeTypeRaw = "exposition"
                self.watchExpositionVM.isPlayTTS = self.isPlayTTS
            case "decision":
                self.watchStoryVM.storyNodeTypeRaw = "decision"
                self.watchDecisionVM.isStartTimer = self.timerStarted
                self.watchDecisionVM.decisionIndex = self.decisionIndex
                self.watchDecisionVM.isInterrupt = self.isInterrupt
                self.watchDecisionVM.isFirstRequest = self.isFirstRequest
            case "ending":
                self.watchStoryVM.storyNodeTypeRaw = "ending"
                self.watchOutroVM.isEndingPlay = true
            default:
                print("Unknown stage received: \(stage)")
            }
        }
    }


    //    func session(_ session: WCSession, didReceiveMessage message: [String: Any])
    //    {
    //        DispatchQueue.main.async {
    //            print("Received message: \(message)")
    //            guard let stageType = message["stage"] as? String,
    //                let stage = Stage(rawValue: stageType)
    //            else {
    //                print("error - stageType: \(message["stage"] ?? "nil")")
    //                return
    //            }
    //
    //            switch stage {
    //            case .idle:
    //                self.watchStartVM?.isStart = self.startContent
    //            case .exposition:
    //                self.watchStoryVM?.storyNodeType = stage
    //                self.watchExpositionVM?.isPlayTTS = self.isPlayTTS
    //            case .decision:
    //                self.watchStoryVM?.storyNodeType = stage
    //                self.watchDecisionVM?.isStartTimer = self.timerStarted
    //                self.watchDecisionVM?.decisionIndex = self.decisionIndex
    //                self.watchDecisionVM?.isInterrupt = self.isInterrupt
    //                self.watchDecisionVM?.isFirstRequest = self.isFirstRequest
    //            case .ending:
    //                self.watchStoryVM?.storyNodeType = stage
    //                self.watchOutroVM?.isEndingPlay = true
    //            }
    //
    //            if let timerStarted = message["timerStarted"] as? Bool {
    //                self.timerStarted = timerStarted
    //            }
    //            if let isPlayTTS = message["isPlayTTS"] as? Bool {
    //                self.isPlayTTS = isPlayTTS
    //            }
    //            if let decisionIndex = message["decisionIndex"] as? Int {
    //                self.decisionIndex = decisionIndex
    //            }
    //            if let isFirstRequest = message["isFirstRequest"] as? Bool {
    //                self.isFirstRequest = isFirstRequest
    //            }
    //            if let isInterrupt = message["isInterrupt"] as? Bool {
    //                self.isInterrupt = isInterrupt
    //            }
    //        }
    //    }
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

}
