export interface MedicalVisionAnalysisResult {
  isDemoPlaceholder: boolean;
  providerName: string;
  modelVersion: string;
  status: 'PENDING_SELECTION' | 'COMPLETED' | 'ERROR';
  findingsSummary: string;
  confidenceScore: number | null; // NULL: NO FAKE CONFIDENCE SCORES
  biRadsCategory: string | null;  // NULL: NO FAKE BI-RADS CLASSIFICATIONS
  recommendations: string[];
  disclaimer: string;
}

export interface IMedicalVisionProvider {
  readonly providerName: string;
  analyzeScan(
    scanId: string,
    storageKey: string,
    modality: string,
  ): Promise<MedicalVisionAnalysisResult>;
}
