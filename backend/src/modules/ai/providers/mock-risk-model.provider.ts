import { Injectable } from '@nestjs/common';
import { IRiskModelProvider, RiskModelResult } from '../interfaces/risk-model.interface';

@Injectable()
export class MockRiskModelProvider implements IRiskModelProvider {
  readonly providerName = 'Lumyra-Mock-Risk-Adapter-v1';

  async assessRisk(inputs: Record<string, any>): Promise<RiskModelResult> {
    const age = inputs.age || 'unspecified';
    const familyHistory = inputs.familyHistoryBreastCancer ? 'Reported' : 'None reported';

    return {
      isDemoPlaceholder: true,
      providerName: this.providerName,
      modelVersion: 'placeholder-risk-v0',
      riskCategory: 'Educational Lifestyle & Family History Assessment (DEMO)',
      riskScore: null, // Strictly null: no fake clinical risk percentages
      riskTier: 'UNDETERMINED',
      keyFactorsIdentified: [
        `Reported age category: ${age}`,
        `First-degree family history: ${familyHistory}`,
        'Personal screening history documented',
      ],
      caveats: [
        'Validated risk models (such as calibrated Gail or Tyrer-Cuzick models) have NOT been integrated in this preview.',
        'This assessment is strictly an educational questionnaire demonstration.',
        'No diagnostic conclusion or personalized cancer probability should be inferred.',
      ],
      disclaimer:
        'CLINICAL NOTICE: Formal statistical breast cancer risk assessment requires validated medical models and physician supervision. This demonstration does not output clinical risk scores or diagnostic recommendations.',
    };
  }
}
