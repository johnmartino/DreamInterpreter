//
//  InputView.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/5/25.
//

import SwiftUI

struct InputView: View {
    @StateObject private var speech = SpeechDictationManager()
    @State private var dreamText = ""
    @FocusState private var isFocused
    private var cornerRadius: CGFloat = 24
    
    let completion: (String) -> Void
    
    init(completion: @escaping (String) -> Void) {
        self.completion = completion
    }
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Describe your dream", text: $dreamText, axis: .vertical)
                .focused($isFocused)
                .textFieldStyle(.plain)
                .multilineTextAlignment(.leading)
                .textInputAutocapitalization(.sentences)
                .disableAutocorrection(false)
                .submitLabel(.done)
                .scrollDismissesKeyboard(.automatic)
            
            HStack {
                Button {
                    if speech.isRecording {
                        speech.stop()
                    } else {
                        Task {
                            if !speech.isAuthorized {
                                await speech.requestAuthorization()
                            }
                            try? speech.start { transcript in
                                self.dreamText = transcript
                            }
                        }
                    }
                } label: {
                    Image(systemName: speech.isRecording ? "mic.fill" : "mic")
                        .tint(Color(.systemBackground))
                        .padding(8)
                        .background {
                            Circle()
                                .foregroundStyle(speech.isRecording ? .red : .primary)
                        }
                }
                
                Spacer()
                
                if !dreamText.isEmpty {
                    Button {
                        dreamText = ""
                    } label: {
                        Image(systemName: "xmark")
                            .tint(Color(.systemBackground))
                            .padding(8)
                            .background { Circle().foregroundStyle(.primary) }
                    }
                }
                
                Button {
                    if speech.isRecording {
                        speech.stop()
                    }
                    completion(dreamText)
                    dreamText = ""
                    isFocused = false
                } label: {
                    Image(systemName: "arrow.up")
                        .tint(Color(.systemBackground))
                        .padding(8)
                        .background {
                            Circle()
                                .foregroundStyle(dreamText.isEmpty ? .secondary : .primary)
                        }
                }
                .disabled(dreamText.isEmpty)
            }
        }
        .padding(8)
        .glassEffect(.regular.tint(Color(.systemBackground).opacity(0.35)), in: .rect(cornerRadius: cornerRadius))
    }
}

#Preview {
    ZStack {
        Color.yellow.ignoresSafeArea()
        InputView { _ in }
            .padding()
    }
}
