//
//  SpeechDictationManager.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/4/25.
//

import Foundation
import Combine
import Speech
import AVFoundation

final class SpeechDictationManager: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var isRecording = false

    private let audioEngine = AVAudioEngine()
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.current)
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    func requestAuthorization() async {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async {
                    self.isAuthorized = (status == .authorized)
                    continuation.resume()
                }
            }
        }
    }

    func start(transcriptionHandler: @escaping (String) -> Void) throws {
        guard !isRecording else { return }
        guard isAuthorized else { return }
        isRecording = true

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        request = SFSpeechAudioBufferRecognitionRequest()
        request?.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        task = speechRecognizer?.recognitionTask(with: request!) { result, error in
            if let result {
                DispatchQueue.main.async {
                    transcriptionHandler(result.bestTranscription.formattedString)
                }
            }
            if error != nil || (result?.isFinal ?? false) {
                self.stop()
            }
        }
    }

    func stop() {
        guard isRecording else { return }
        isRecording = false
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        task = nil
        request = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
