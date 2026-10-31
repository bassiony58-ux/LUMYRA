export interface ChatMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
}

export interface AiAssistantResponse {
  text: string;
  disclaimer: string;
  isDemoPlaceholder: boolean;
  providerName: string;
  suggestedActions: string[];
}

export interface IAiAssistantProvider {
  readonly providerName: string;
  generateResponse(
    history: ChatMessage[],
    userQuery: string,
    locale?: string,
  ): Promise<AiAssistantResponse>;
}
