import { Injectable } from '@nestjs/common';
import {
  IAiAssistantProvider,
  ChatMessage,
  AiAssistantResponse,
} from '../interfaces/ai-assistant.interface';

@Injectable()
export class MockAiAssistantProvider implements IAiAssistantProvider {
  readonly providerName = 'Lumyra-Mock-Conversational-Adapter-v1';

  async generateResponse(
    history: ChatMessage[],
    userQuery: string,
    locale: string = 'ar',
  ): Promise<AiAssistantResponse> {
    const isArabic = locale.toLowerCase().startsWith('ar');
    const q = userQuery.toLowerCase().trim();

    // Check if query is breast-health related
    const breastKeywords = [
      'ثدي', 'كتل', 'ورم', 'كيس', 'سونار', 'ماموجرام', 'مامو', 'فحص', 'عينة', 'خزعة',
      'حلمة', 'إفرازات', 'ألم', 'احمرار', 'التهاب', 'غدد', 'سرطان', 'أورام', 'هرمون',
      'تاموكسيفين', 'علاج', 'أشعة', 'أعراض', 'بي رادس', 'طمث', 'دورة', 'تغذية', 'رضاعة',
      'breast', 'lump', 'tumor', 'cyst', 'sonar', 'ultrasound', 'mammogram', 'biopsy',
      'nipple', 'discharge', 'pain', 'mastitis', 'cancer', 'fibroadenoma', 'tamoxifen', 'birads'
    ];

    const isBreastRelated = breastKeywords.some((k) => q.includes(k));

    let text = '';

    if (!isBreastRelated) {
      text = isArabic
        ? 'عذراً يا عزيزتي 🌸، أنا لوميرا المساعد الطبي المتخصص حصرياً في صحة وأمراض وأورام الثدي والفحوصات المتعلقة بها. لا يمكنني الإجابة إلا على الأسئلة الطبية والتوعوية المرتبطة بصحة الثدي وكيفية رعايتها ومتابعتها. يسعدني الإجابة على أي سؤال يخص صحة ثديكِ، الفحص الذاتي، أو الأشعة والتحاليل الطبية.'
        : 'I apologize 🌸, I am Lumyra, an AI companion dedicated exclusively to breast health, oncology, and related clinical care. I cannot answer queries outside breast wellness, diagnostics, and treatment. Please feel free to ask any question regarding breast lumps, mammography, clinical care, or breast health.';
    } else if (q.includes('كتل') || q.includes('شكيت') || q.includes('lump')) {
      text = isArabic
        ? `أهلاً بكِ، واطمئني تماماً يا عزيزتي 🌸:
١. أكثر من ٨٠٪ من كتل الثدي حميدة تماماً (مثل الأكياس المائية البسيطة أو الأورام الغدية الليفية).
٢. تجنبي الضغط المتكرر أو العنيف على المنطقة لتفادي تهيج الأنسجة.
٣. يوصى بحجز موعد استشارة سريرية مع استشاري جراحة أورام الثدي للفحص السريري المباشر.
٤. الفحص المتوقع: سيطلب الطبيب فحص سونار للثدي (إذا كان عمركِ أقل من ٤٠ سنة) أو ماموجرام رقمي لتحديد طبيعة الكتلة بدقة متناهية.
٥. لاحظي ما إذا كانت الكتلة متحركة أو ثابتة، وتاريخ ظهورها بالنسبة للدورة الشهرية.`
        : `Rest assured 🌸:
1. Over 80% of breast lumps are completely benign (such as fluid-filled cysts or fibroadenomas).
2. Avoid forcefully palpating or squeezing the area repeatedly.
3. Schedule an in-person clinical evaluation with a specialized breast surgeon.
4. Expected diagnostic steps: Breast ultrasound (for women under 40) or digital mammogram to evaluate tissue characteristics.
5. Note whether the lump is mobile or tender, and its relation to your menstrual cycle.`;
    } else if (q.includes('ماموجرام') || q.includes('mammogram')) {
      text = isArabic
        ? `للاستعداد الأمثل لفحص الماموجرام 🌸:
• تجنبي استخدام مزيلات العرق، البودرة، أو العطور يوم الفحص لأنها قد تظهر كبقع بيضاء على صورة الأشعة.
• ارتدي ملابس مريحة من قطعتين لسهولة الفحص.
• أفضل توقيت هو بعد انتهاء الدورة الشهرية بأسبوع حيث يكون الثدي في أقل حالات الحساسية للألم.
• أحضري أي صور ماموجرام سابقة للمقارنة وتتبع التغيرات الزمنية.`
        : `Preparation for your mammogram 🌸:
• Avoid deodorants, powders, or lotions on the day of the exam.
• Wear a two-piece outfit for comfort.
• The ideal timing is one week after your period when breast tissue is least sensitive.
• Bring previous imaging films/reports for longitudinal comparison.`;
    } else if (q.includes('فحص ذاتي') || q.includes('self-exam')) {
      text = isArabic
        ? `دليل الفحص الذاتي الشهري 🌸:
• التوقيت المثالي: بعد انتهاء الدورة الشهرية بـ ٥ إلى ٧ أيام.
• الخطوة ١ (أمام المرآة): تأكدي من تماثل الثديين، وعدم وجود انبعاج بالجلد أو تغير بشكل الحلمة.
• الخطوة ٢ (رفع الذراعين): تحققي من نفس العلامات مع رفع اليدين لأعلى.
• الخطوة ٣ (الفحص باللمس): استخدمي باطن أصابع يدكِ الثلاث بحركات دائرية خفيفة ثم متوسطة لتغطية الثدي ومنطقة تحت الإبط بالكامل.`
        : `Monthly self-exam guide 🌸:
• Timing: 5-7 days after your period ends.
• Step 1 (Visual): Inspect symmetry, skin texture, and nipple contour before a mirror.
• Step 2 (Arms raised): Re-inspect with arms raised overhead.
• Step 3 (Palpation): Use the pads of your three middle fingers in small circular motions covering the breast and underarm.`;
    } else {
      text = isArabic
        ? `شكراً لاستفساركِ الهام حول صحة الثدي 🌸. يسعدني تقديم هذه المعلومات التوعوية:
• الحفاظ على المتابعة الدورية والفحص السريري السنوي هو خط الدفاع الأول لصحة ثديكِ.
• إذا كنتِ تشعرين بأي أعراض غير معتادة (مثل تغير في ملمس الجلد، إفرازات حلمية، أو ألم غير مرتبط بالطمث)، نوصيكِ بمناقشتها مع طبيبكِ المعالج.
• يمكنكِ تسجيل هذا السؤال في "يومياتكِ" داخل التطبيق لمناقشته خلال زيارتكِ القادمة.`
        : `Thank you for your breast health question 🌸:
• Routine screening and clinical checkups remain your best health shield.
• If you notice unusual changes (skin texture, nipple discharge, or non-cyclical pain), discuss them promptly with your doctor.
• You can save this point in your Lumyra Journal for your next clinical visit.`;
    }

    const disclaimer = isArabic
      ? 'تنبيه طبي: رد المساعد الصحي هو نموذج تجريبي لأغراض العرض والتوعية فقط، ولا يمثل استشارة أو تشخيصاً طبياً معتمداً.'
      : 'Medical Disclaimer: This assistant response is a demonstration placeholder for educational awareness only and does not constitute medical advice or diagnosis.';

    const suggestedActions = isArabic
      ? [
          'حجز موعد مع طبيب معتمد',
          'دليل الفحص الذاتي الشهري',
          'استكشاف مراكز الفحص القريبة',
        ]
      : [
          'Book appointment with certified doctor',
          'Monthly self-exam guide',
          'Explore nearby screening centers',
        ];

    return {
      text,
      disclaimer,
      isDemoPlaceholder: true,
      providerName: this.providerName,
      suggestedActions,
    };
  }
}
