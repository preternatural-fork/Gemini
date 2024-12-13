//
// Copyright (c) Vatsal Manot
//

import LargeLanguageModels
import Swallow

extension AbstractLLM.ChatMessage {
    public init(
        _from modelContent: ModelContent
    ) throws {
        var content: PromptLiteral = .empty
        let role = try AbstractLLM.ChatRole(_from: try modelContent._role.unwrap())
        
        for part in modelContent.parts {
            content.append(PromptLiteral(_from: part))
        }
        
        self.init(role: role, content: content)
    }
}

extension PromptLiteral {
    init(_from part: ModelContent.Part) {
        switch part {
            case .text(let value):
                self.init(stringLiteral: value)
            case .data(let mimetype, _):

                self.init(stringLiteral: "[Data: \(mimetype)]")
            case .fileData(let mimetype, let uri):

                self.init(stringLiteral: "[File: \(mimetype) at \(uri)]")
            case .functionCall(let functionCall):

                self.init(stringLiteral: "Function Call: \(functionCall.name)")
            case .functionResponse(let functionResponse):
                
                self.init(stringLiteral: "Function Response: \(functionResponse.name)")
            case .executableCode(let executableCode):
                
                self.init(stringLiteral: """
                ```\(executableCode.language.lowercased())
                \(executableCode.code)
                ```
                """)
            case .codeExecutionResult(let result):

                let status = result.outcome == .ok ? "Success" : "Error"
                self.init(stringLiteral: """
                Execution Result (\(status)):
                ```
                \(result.output)
                ```
                """)
        }
    }
}

extension AbstractLLM.ChatRole {
    init(_from role: ModelContent._Role) throws {
        switch role {
            case .systemInstruction:
                self = .system
            case .model:
                self = .assistant // FIXME: Should we create a strategy selection for Gemini.Client to make the choice of converting from "model" to "assistant" explicit? _Is_ the semantic of a 'model' the same as that of an 'assistant' ¯\_(ツ)_/¯
            case .user:
                self = .user
        }
    }
}

extension AbstractLLM.ChatCompletion.StopReason {
    public init(_from finishReason: FinishReason) throws {
        switch finishReason {
            case .unknown:
                TODO.unimplemented
            case .unspecified:
                TODO.unimplemented
            case .stop:
                self.init(type: .endTurn) // FIXME: It could be stop sequence or natural end, we need to improve `StopReason` to accomodate for this ambiguity
            case .maxTokens:
                self.init(type: .maxTokens)
            case .safety:
                TODO.unimplemented
            case .recitation:
                TODO.unimplemented
            case .other:
                TODO.unimplemented
        }
    }
}
