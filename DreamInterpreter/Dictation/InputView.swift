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
            // MARK: - Text Field
            TextField("Describe your dream", text: $dreamText, axis: .vertical)
                .focused($isFocused)
                .textFieldStyle(.plain)
                .multilineTextAlignment(.leading)
                .textInputAutocapitalization(.sentences)
                .disableAutocorrection(false)
                .submitLabel(.done)
            
            // MARK: - Buttons
            HStack(spacing: 16) {
                Image(systemName: speech.isRecording ? "mic.fill" : "mic")
                    .foregroundStyle(speech.isRecording ? .white : .primary)
                    .padding(8)
                    .glassEffect(speech.isRecording ? .regular.tint(.red).interactive() : .regular.interactive(), in: .circle)
                    .onTapGesture {
                        if speech.isRecording {
                            speech.stop()
                        } else {
                            startTranscribing()
                        }
                    }
                
                Spacer()
                
                HStack(spacing: 8) {
                    if isFocused {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .foregroundStyle(.primary)
                            .padding(8)
                            .glassEffect(.regular.interactive(), in: .circle)
                            .transition(
                                .asymmetric(
                                    insertion: .offset(x: -20).combined(with: .opacity).combined(with: .scale),
                                    removal: .offset(x: 20).combined(with: .opacity).combined(with: .scale)
                                )
                            )
                            .onTapGesture {
                                isFocused = false
                            }
                    }
                    
                    if !dreamText.isEmpty {
                        Image(systemName: "xmark")
                            .foregroundStyle(.primary)
                            .padding(8)
                            .glassEffect(.regular.interactive(), in: .circle)
                            .transition(
                                .asymmetric(
                                    insertion: .offset(x: -20).combined(with: .opacity).combined(with: .scale),
                                    removal: .offset(x: 20).combined(with: .opacity).combined(with: .scale)
                                )
                            )
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    dreamText = ""
                                }
                                if speech.isRecording {
                                    speech.stop()
                                }
                            }
                    }
                    
                    Image(systemName: "arrow.up")
                        .foregroundStyle(dreamText.isEmpty ? .secondary : .primary)
                        .padding(8)
                        .glassEffect(.regular.interactive(), in: .circle)
                        .disabled(dreamText.isEmpty)
                        .onTapGesture {
                            if !dreamText.isEmpty {
                                let text = dreamText
                                if speech.isRecording {
                                    speech.stop()
                                }
                                withAnimation(.snappy) {
                                    dreamText = ""
                                    isFocused = false
                                }
                                completion(text)
                            }
                        }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: dreamText)
        }
        .padding(8)
        .glassEffect(.regular.tint(Color(.systemBackground).opacity(0.35)), in: .rect(cornerRadius: cornerRadius))
        .contentShape(Rectangle())
        .onTapGesture {
            // Consume tap so it doesn't reach views underneath.
            // You can also dismiss the keyboard here if desired:
            // isFocused = false
        }
    }
    
    private func startTranscribing() {
        Task {
            if !speech.isAuthorized {
                await speech.requestAuthorization()
            }
            try? speech.start { transcript in
                self.dreamText = transcript
            }
        }
    }
}

#Preview {
    ZStack {
        Color.yellow.ignoresSafeArea()
        InputView { _ in }
            .padding()
    }
}
