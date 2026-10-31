export interface RiskModelResult {
  isDemoPlaceholder: boolean;
  providerName: string;
  modelVersion: string;
  riskCategory: string;
  riskScore: number | null; // NULL: NO FAKE CLINICAL RISK PERCENTAGES
  riskTier: 'LOW' | 'AVERAGE' | 'ELEVATED' | 'HIGH' | 'UNDETERMINED';
  keyFactorsIdentified: string[];
  caveats: string[];
  disclaimer: string;
}

export interface IRiskModelProvider {
  readonly providerName: string;
  assessRisk(inputs: Record<string, any>): Promise<RiskModelResult>;
}
