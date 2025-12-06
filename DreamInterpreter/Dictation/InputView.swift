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
    
    let borderColor: Color
    let completion: (String) -> Void
    
    init(borderColor: Color = .clear, completion: @escaping (String) -> Void) {
        self.borderColor = borderColor
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
        .glassEffect(.clear, in: .rect(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(.secondary, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

#Preview {
    ZStack {
        Color.yellow.ignoresSafeArea()
        InputView(borderColor: .gray) { _ in }
            .padding()
    }
}
