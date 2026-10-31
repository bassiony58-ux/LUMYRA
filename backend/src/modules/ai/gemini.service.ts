import { Injectable, Logger, BadRequestException, InternalServerErrorException } from '@nestjs/common';

export interface MedicalImageAnalysisResult {
  isMedicalScan: boolean;
  detectedModality: 'ULTRASOUND' | 'MAMMOGRAPHY' | 'MRI' | 'REPORT' | 'NON_MEDICAL' | 'OTHER';
  finding: 'benign' | 'malignant' | 'normal' | 'inconclusive';
  confidence: number;
  probabilities: {
    benign: number;
    malignant: number;
    normal: number;
  };
  biRadsCategory: string;
  clinicalDescriptionAr: string;
  clinicalDescriptionEn: string;
  requiresUrgentDoctorVisit: boolean;
  triagePriority: 'URGENT' | 'ROUTINE';
  recommendations: string[];
  disclaimerAr: string;
  disclaimerEn: string;
  modelVersion: string;
  providerName: string;
}

export interface ClinicalRiskAssessmentResult {
  summaryAr: string;
  summaryEn: string;
  estimatedRiskCategory: 'AVERAGE' | 'MODERATE' | 'HIGH' | 'GENETIC_CARRIER_HIGH';
  fiveYearRiskPerspectiveAr: string;
  lifetimeRiskPerspectiveAr: string;
  gailModelComparisonAr: string;
  tyrerCuzickComparisonAr: string;
  recommendedActionPlanAr: string[];
  talkingPointsForDoctor: string[];
  suggestedScreeningScheduleAr: string;
  disclaimer: string;
}

@Injectable()
export class GeminiService {
  private readonly logger = new Logger(GeminiService.name);
  private readonly apiKey: string | null = null;
  private readonly candidateModels = [
    'gemini-3.5-flash-lite',
    'gemini-3.6-flash',
    'gemini-3.5-flash',
    'gemini-3.1-flash-lite-preview',
  ];

  constructor() {
    this.apiKey = process.env.GEMINI_API_KEY || process.env.GOOGLE_GEMINI_API_KEY || null;
    if (this.apiKey) {
      this.logger.log('GeminiService initialized with active API Key.');
    } else {
      this.logger.warn('GeminiService: GEMINI_API_KEY is not defined in environment.');
    }
  }

  private async callGeminiWithFallback(payload: any): Promise<{ data: any; model: string }> {
    if (!this.apiKey) {
      throw new InternalServerErrorException('GEMINI_API_KEY is not configured in backend .env');
    }

    let lastError: any = null;

    for (const model of this.candidateModels) {
      const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${this.apiKey}`;
      try {
        const response = await fetch(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload),
        });

        if (!response.ok) {
          const errText = await response.text();
          this.logger.warn(`Gemini model ${model} HTTP ${response.status}: ${errText.slice(0, 150)}`);
          lastError = new Error(`HTTP ${response.status}: ${errText.slice(0, 150)}`);
          continue;
        }

        const resJson = await response.json();
        const text = resJson?.candidates?.[0]?.content?.parts?.[0]?.text;
        if (!text) {
          this.logger.warn(`Gemini model ${model} returned empty response.`);
          continue;
        }

        return { data: text, model };
      } catch (err: any) {
        this.logger.warn(`Gemini model ${model} call failed: ${err.message}`);
        lastError = err;
      }
    }

    throw new InternalServerErrorException(
      `تعذر الاتصال بمحرك الذكاء الاصطناعي السحابي: ${lastError?.message || 'Gemini unavailable'}`,
    );
  }

  async analyzeMedicalImage(
    imageBuffer: Buffer,
    mimeType: string,
    isDoctor: boolean = false,
  ): Promise<MedicalImageAnalysisResult> {
    const base64Data = imageBuffer.toString('base64');

    const promptText = `You are a certified senior clinical oncologist and expert breast radiologist.
Analyze this image thoroughly with high clinical rigor.

Respond strictly in valid JSON matching this schema:
{
  "isMedicalScan": boolean,
  "detectedModality": "ULTRASOUND" | "MAMMOGRAPHY" | "MRI" | "REPORT" | "NON_MEDICAL" | "OTHER",
  "finding": "benign" | "malignant" | "normal" | "inconclusive",
  "confidence": number between 0.0 and 1.0,
  "probabilities": {
    "benign": number between 0.0 and 1.0,
    "malignant": number between 0.0 and 1.0,
    "normal": number between 0.0 and 1.0
  },
  "biRadsCategory": string (e.g. "BI-RADS 1 - Negative", "BI-RADS 2 - Benign", "BI-RADS 3 - Probably Benign", "BI-RADS 4 - Suspicious", "BI-RADS 5 - Highly Suggestive", or "Not Applicable"),
  "clinicalDescriptionAr": string (detailed, objective, compassionate explanation in Arabic),
  "clinicalDescriptionEn": string (detailed clinical radiology explanation in English),
  "requiresUrgentDoctorVisit": boolean (true if malignant or BI-RADS >= 4, else false),
  "recommendations": string[] (actionable, clinical guidance in Arabic)
}

CRITICAL RULES:
1. If the image is NOT a medical scan or breast report (e.g. selfie, logo, generic object, solid blank color):
   - Set "isMedicalScan": false
   - Set "detectedModality": "NON_MEDICAL"
   - Set "finding": "inconclusive"
   - Set "requiresUrgentDoctorVisit": false
   - In "clinicalDescriptionAr", explain clearly that this is not a medical scan and politely ask to upload an authentic breast ultrasound, mammogram, or clinical report.
2. If it IS a medical scan (Ultrasound, Mammogram, MRI, or Pathology/Lab Report):
   - Provide genuine clinical insights based on actual visible features.
   - Separate objective image finding from clinical referral priority.
   - For benign or normal scans, do NOT give false absolute assurance; always emphasize that clinical correlation is mandatory.
   - Ensure probabilities sum to 1.0.

Return ONLY pure JSON. No markdown code blocks.`;

    const payload = {
      contents: [
        {
          parts: [
            { text: promptText },
            {
              inlineData: {
                mimeType: mimeType || 'image/jpeg',
                data: base64Data,
              },
            },
          ],
        },
      ],
      generationConfig: {
        temperature: 0.15,
        responseMimeType: 'application/json',
      },
    };

    const { data: rawJsonText, model } = await this.callGeminiWithFallback(payload);

    let parsed: any;
    try {
      const cleanJson = rawJsonText.trim().replace(/^```json\s*/i, '').replace(/```$/i, '').trim();
      parsed = JSON.parse(cleanJson);
    } catch (e) {
      this.logger.error(`Failed to parse Gemini output as JSON: ${rawJsonText.slice(0, 200)}`);
      throw new BadRequestException('فشل في تحليل الاستجابة السريرية من محرك الذكاء الاصطناعي');
    }

    const finding = (parsed.finding || 'inconclusive').toLowerCase();
    const isUrgent = parsed.requiresUrgentDoctorVisit === true || finding === 'malignant';

    return {
      isMedicalScan: parsed.isMedicalScan !== false,
      detectedModality: parsed.detectedModality || 'OTHER',
      finding: finding as any,
      confidence: typeof parsed.confidence === 'number' ? parsed.confidence : 0.8,
      probabilities: parsed.probabilities || {
        benign: finding === 'benign' ? 0.85 : 0.1,
        malignant: finding === 'malignant' ? 0.85 : 0.1,
        normal: finding === 'normal' ? 0.85 : 0.05,
      },
      biRadsCategory: parsed.biRadsCategory || 'BI-RADS Inconclusive',
      clinicalDescriptionAr: parsed.clinicalDescriptionAr || 'تم استكمال الفحص بواسطة الذكاء الاصطناعي.',
      clinicalDescriptionEn: parsed.clinicalDescriptionEn || 'Analysis completed by AI assistant.',
      requiresUrgentDoctorVisit: isUrgent,
      triagePriority: isUrgent ? 'URGENT' : 'ROUTINE',
      recommendations: Array.isArray(parsed.recommendations) ? parsed.recommendations : [
        'مراجعة الطبيب المعالج لمطابقة النتيجة مع الفحص السريري.',
      ],
      disclaimerAr: 'تنبيه سريري إلزامي: هذا التحليل مدعوم بالذكاء الاصطناعي المتقدم لغرض التوجيه والاسترشاد السريري فقط، ولا يمثل تشخيصاً طبياً نهائياً أو بديلاً عن الفحص المباشر لدى الطبيب المختص.',
      disclaimerEn: 'MANDATORY CLINICAL NOTICE: This AI-generated report is an adjunctive decision-support aid. It does not constitute a final diagnosis or eliminate the necessity of formal physical evaluation by a licensed physician.',
      modelVersion: model,
      providerName: 'Google Gemini Vision AI',
    };
  }

  async assessClinicalRisk(answers: any, isArabic: boolean = true): Promise<ClinicalRiskAssessmentResult> {
    const promptText = `You are a clinical oncologist specializing in breast cancer risk assessment and hereditary cancer genetics.
Analyze this comprehensive patient questionnaire intake data and evaluate the clinical risk profile based on international guidelines (comparative principles of the Gail Model/BCRAT and Tyrer-Cuzick/IBIS models).

Patient Answers JSON:
${JSON.stringify(answers, null, 2)}

Provide strict JSON response with:
{
  "summaryAr": string (compassionate, professional clinical summary in Arabic),
  "summaryEn": string (concise oncology summary in English),
  "estimatedRiskCategory": "AVERAGE" | "MODERATE" | "HIGH" | "GENETIC_CARRIER_HIGH",
  "fiveYearRiskPerspectiveAr": string (qualitative and contextual 5-year perspective without asserting false mathematical certainty),
  "lifetimeRiskPerspectiveAr": string (qualitative lifetime risk perspective contextualizing family history and reproductive factors),
  "gailModelComparisonAr": string (how the Gail model factors like age at menarche, parity, and first-degree relatives apply to her profile),
  "tyrerCuzickComparisonAr": string (how extensive family pedigree, aunts, grandmothers, and BRCA status influence this assessment),
  "recommendedActionPlanAr": string[] (3-5 concrete medical steps like scheduling clinical breast exam, genetic counseling, or annual imaging),
  "talkingPointsForDoctor": string[] (3-5 focused questions/points for the patient to ask her physician in clinic),
  "suggestedScreeningScheduleAr": string (age-appropriate routine screening timeline recommendation),
  "disclaimer": string (clear ethical reminder that this is an educational risk assessment, not a substitute for formal genetic testing or doctor consultation)
}

Return ONLY pure JSON.`;

    const payload = {
      contents: [{ parts: [{ text: promptText }] }],
      generationConfig: {
        temperature: 0.2,
        responseMimeType: 'application/json',
      },
    };

    const { data: rawJsonText } = await this.callGeminiWithFallback(payload);

    let parsed: any;
    try {
      const cleanJson = rawJsonText.trim().replace(/^```json\s*/i, '').replace(/```$/i, '').trim();
      parsed = JSON.parse(cleanJson);
    } catch (e) {
      this.logger.error(`Failed to parse Gemini risk assessment: ${rawJsonText.slice(0, 200)}`);
      throw new BadRequestException('فشل في استخراج تقييم المخاطر من محرك الذكاء الاصطناعي');
    }

    return {
      summaryAr: parsed.summaryAr || 'تم إعداد ملخص التقييم السريري بناءً على إجاباتك.',
      summaryEn: parsed.summaryEn || 'Clinical risk assessment generated.',
      estimatedRiskCategory: parsed.estimatedRiskCategory || 'AVERAGE',
      fiveYearRiskPerspectiveAr: parsed.fiveYearRiskPerspectiveAr || 'المخاطر متوافقة مع المعدلات العامة لمن هم في نفس الفئة العمرية.',
      lifetimeRiskPerspectiveAr: parsed.lifetimeRiskPerspectiveAr || 'يوصى بالمتابعة الدورية المنتظمة وفق الإرشادات السريرية.',
      gailModelComparisonAr: parsed.gailModelComparisonAr || 'وفق معايير Gail، تؤثر العوامل الإنجابية والتاريخ الأولي بشكل استرشادي.',
      tyrerCuzickComparisonAr: parsed.tyrerCuzickComparisonAr || 'وفق معايير Tyrer-Cuzick، يعكس التاريخ العائلي الموسع الحاجة لاستشارة وراثية عند وجود إصابات متعددة.',
      recommendedActionPlanAr: Array.isArray(parsed.recommendedActionPlanAr) ? parsed.recommendedActionPlanAr : [
        'مناقشة التقرير مع طبيب الرعاية الأولية أو أخصائي جراحة الثدي.',
        'الالتزام بالفحص الذاتي الشهري بعد انتهاء الدورة الشهرية.',
      ],
      talkingPointsForDoctor: Array.isArray(parsed.talkingPointsForDoctor) ? parsed.talkingPointsForDoctor : [
        'هل أحتاج إلى تصوير سنوي بالماموجرام أم السونار التكميلي؟',
        'هل التاريخ العائلي لدي يستدعي إجراء استشارة وراثية موسعة؟',
      ],
      suggestedScreeningScheduleAr: parsed.suggestedScreeningScheduleAr || 'الفحص السريري الدوري كل عام، مع تصوير الثدي بدءاً من سن 40 أو أبكر حسب توصية الطبيب.',
      disclaimer: parsed.disclaimer || 'تنبيه: هذا التقييم لأغراض التوعية والإرشاد الصحي فقط، ولا يمثل نسبة إحصائية قاطعة أو بديلاً عن الفحص السريري المباشر.',
    };
  }

  async generateChatReply(
    history: { role: 'user' | 'assistant'; content: string }[],
    userMessage: string,
    locale: string = 'ar',
  ): Promise<string> {
    const isAr = locale.startsWith('ar');

    const systemPrompt = `You are Lumyra (لوميرا), a specialized clinical AI assistant exclusively dedicated to Breast Health and Breast Oncology in Egypt.

IMPORTANT CORE GUARDRAILS & TOPIC ENFORCEMENT:
1. STRICTLY REJECT OFF-TOPIC QUESTIONS:
   You are an exclusive medical specialist for Breast Health. If the user asks about ANYTHING outside breast health, breast anatomy, breast cancer, breast lumps, cysts, fibroadenoma, mastitis, mammograms, ultrasounds, biopsy, breast pain, hormone therapy, self-exams, or related oncology (e.g. food recipes like "اعمل ملوخيه ازاي", cooking, general medicine outside breast health, programming, sports, football, general chatter, mathematics, politics, etc.), you MUST STRICTLY and politely refuse to answer:
   In Arabic:
   "عذراً يا عزيزتي 🌸، أنا لوميرا المساعد الطبي المتخصص حصرياً في صحة وأمراض وأورام الثدي والفحوصات المتعلقة بها. لا يمكنني الإجابة إلا على الأسئلة الطبية والتوعوية المرتبطة بصحة الثدي وكيفية رعايتها ومتابعتها. يسعدني الإجابة على أي سؤال يخص صحة ثديكِ، الفحص الذاتي، أو الأشعة والتحاليل الطبية."
   In English:
   "I apologize 🌸, I am Lumyra, an AI companion dedicated exclusively to breast health, oncology, and related clinical care. I cannot answer queries outside breast wellness, diagnostics, and treatment. Please feel free to ask any question regarding breast lumps, mammography, clinical care, or breast health."

2. ANSWER ANY QUESTION RELATED TO BREAST DISEASE THOROUGHLY & COMPASSIONATELY:
   If the user asks ANY question related to breast health, disease, lumps, tumors, symptoms, what to do if they feel a lump, tests (ultrasound, mammogram, MRI, core biopsy), BI-RADS scores, staging, surgical options (lumpectomy, mastectomy), reconstruction, chemotherapy, radiotherapy, endocrine therapy (Tamoxifen), lifestyle/diet for breast health, emotional support, or what to ask their doctor:
   - Provide a thorough, scientifically accurate, compassionate, structured, and step-by-step clinical answer in ${isAr ? 'compassionate, clear Arabic' : 'clear, compassionate English'}.
   - If asked about feeling a lump ("اعمل ايه لو شكيت بوجود كتله في الثدي"):
     1. Reassure her warmly that over 80% of breast lumps are completely benign (cysts, fibroadenomas).
     2. Recommend not repeatedly squeezing or pressing forcefully on the area.
     3. Advise booking a clinical breast examination with a specialized breast surgeon.
     4. Explain that an ultrasound (for younger women) or digital mammogram (over 40) is the standard next diagnostic step.
     5. Advise noticing any accompanying signs (skin dimpling, nipple discharge, mobility of the lump).

3. ETHICAL GUARDRAIL:
   Warmly encourage in-person medical evaluation while empowering the patient with knowledge.`;

    const contents = [
      {
        role: 'user',
        parts: [{ text: systemPrompt }],
      },
      {
        role: 'model',
        parts: [{ text: isAr ? 'أهلاً بكِ، أنا لوميرا رفيقتكِ الموثوقة لصحة الثدي. أنا هنا للإجابة على استفساراتكِ ومساعدتكِ في كل خطوة.' : 'Hello, I am Lumyra, your trusted breast health companion. How can I assist you today?' }],
      },
      ...history.map((h) => ({
        role: h.role === 'assistant' ? 'model' : 'user',
        parts: [{ text: h.content }],
      })),
      {
        role: 'user',
        parts: [{ text: userMessage }],
      },
    ];

    const payload = {
      contents,
      generationConfig: {
        temperature: 0.35,
        maxOutputTokens: 1024,
      },
    };

    const { data: rawText } = await this.callGeminiWithFallback(payload);
    return rawText.trim();
  }
}
