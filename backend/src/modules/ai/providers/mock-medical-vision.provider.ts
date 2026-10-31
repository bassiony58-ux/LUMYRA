import { Injectable } from '@nestjs/common';
import {
  IMedicalVisionProvider,
  MedicalVisionAnalysisResult,
} from '../interfaces/medical-vision.interface';

@Injectable()
export class MockMedicalVisionProvider implements IMedicalVisionProvider {
  readonly providerName = 'Lumyra-Mock-Vision-Adapter-v1';

  async analyzeScan(
    scanId: string,
    storageKey: string,
    modality: string,
  ): Promise<MedicalVisionAnalysisResult> {
    return {
      isDemoPlaceholder: true,
      providerName: this.providerName,
      modelVersion: 'unselected-demo-v0',
      status: 'PENDING_SELECTION',
      findingsSummary:
        'Preliminary scan receipt acknowledged. Medical imaging AI model integration is intentionally deferred pending formal clinical validation and provider selection. No automated diagnostic inference has been executed.',
      confidenceScore: null, // Strictly null: no fake confidence percentages
      biRadsCategory: null,  // Strictly null: no fake BI-RADS classification
      recommendations: [
        'Share this scan directly with your licensed oncologist or radiologist.',
        'Request a secondary clinical review through your Lumyra care team.',
        'Follow your routine mammographic screening schedule as recommended by your physician.',
      ],
      disclaimer:
        'IMPORTANT: Medical image analysis models have not yet been connected. This screen shows placeholder demonstration structure. Never rely on automated software for diagnostic confirmation.',
    };
  }
}
