import { MockAiAssistantProvider } from './mock-ai-assistant.provider';
import { MockMedicalVisionProvider } from './mock-medical-vision.provider';
import { MockRiskModelProvider } from './mock-risk-model.provider';

describe('AI & Risk Provider Abstractions (Unselected Model Enforcements)', () => {
  describe('MockAiAssistantProvider', () => {
    let provider: MockAiAssistantProvider;

    beforeEach(() => {
      provider = new MockAiAssistantProvider();
    });

    it('should explicitly mark output as demo placeholder and include clinical disclaimer in Arabic', async () => {
      const response = await provider.generateResponse([], 'ما هي أعراض سرطان الثدي؟', 'ar');

      expect(response.isDemoPlaceholder).toBe(true);
      expect(response.providerName).toContain('Mock');
      expect(response.disclaimer).toContain('تنبيه طبي');
      expect(response.text).toContain('لوميرا');
      expect(response.suggestedActions.length).toBeGreaterThan(0);
    });

    it('should return English disclaimer and demo flag when locale is en', async () => {
      const response = await provider.generateResponse([], 'What are breast cancer symptoms?', 'en');

      expect(response.isDemoPlaceholder).toBe(true);
      expect(response.disclaimer).toContain('Medical Disclaimer');
      expect(response.suggestedActions.length).toBeGreaterThan(0);
    });
  });

  describe('MockMedicalVisionProvider', () => {
    let provider: MockMedicalVisionProvider;

    beforeEach(() => {
      provider = new MockMedicalVisionProvider();
    });

    it('should NEVER return fake confidence scores or fake BI-RADS categories', async () => {
      const result = await provider.analyzeScan('scan-001', 'patients/pat-1/scans/s.dcm', 'MAMMOGRAM');

      expect(result.isDemoPlaceholder).toBe(true);
      expect(result.status).toBe('PENDING_SELECTION');
      expect(result.confidenceScore).toBeNull();
      expect(result.biRadsCategory).toBeNull();
      expect(result.disclaimer).toContain('Medical image analysis models have not yet been connected');
      expect(result.recommendations).toContain(
        'Share this scan directly with your licensed oncologist or radiologist.',
      );
    });
  });

  describe('MockRiskModelProvider', () => {
    let provider: MockRiskModelProvider;

    beforeEach(() => {
      provider = new MockRiskModelProvider();
    });

    it('should NEVER calculate fake clinical risk percentages without validated medical models', async () => {
      const result = await provider.assessRisk({
        age: 45,
        familyHistoryBreastCancer: true,
      });

      expect(result.isDemoPlaceholder).toBe(true);
      expect(result.riskScore).toBeNull();
      expect(result.riskTier).toBe('UNDETERMINED');
      expect(result.caveats.length).toBeGreaterThan(0);
      expect(result.caveats[0]).toContain('Validated risk models');
      expect(result.disclaimer).toContain('does not output clinical risk scores');
    });
  });
});
