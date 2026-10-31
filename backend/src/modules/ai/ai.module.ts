import { Module } from '@nestjs/common';
import { AiService } from './ai.service';
import { AiController } from './ai.controller';
import { GeminiService } from './gemini.service';
import { MockAiAssistantProvider } from './providers/mock-ai-assistant.provider';
import { MockMedicalVisionProvider } from './providers/mock-medical-vision.provider';
import { MockRiskModelProvider } from './providers/mock-risk-model.provider';

@Module({
  controllers: [AiController],
  providers: [
    AiService,
    GeminiService,
    MockAiAssistantProvider,
    MockMedicalVisionProvider,
    MockRiskModelProvider,
  ],
  exports: [
    AiService,
    GeminiService,
    MockAiAssistantProvider,
    MockMedicalVisionProvider,
    MockRiskModelProvider,
  ],
})
export class AiModule {}
