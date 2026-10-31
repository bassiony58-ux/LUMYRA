# -*- coding: utf-8 -*-
import os

html_content = """<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>دليل مشروع لوميرا (LUMYRA) الشامل للفريق</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;800;900&family=Tajawal:wght@400;500;700;800&display=swap');

        @page {
            size: A4;
            margin: 18mm 14mm 20mm 14mm;
            @bottom-right {
                content: "منظومة لوميرا (LUMYRA) — الدليل التقني والسريري الشامل";
                font-family: 'Cairo', sans-serif;
                font-size: 9px;
                color: #8C7B7E;
            }
            @bottom-left {
                content: "صفحة " counter(page);
                font-family: 'Cairo', sans-serif;
                font-size: 9px;
                font-weight: bold;
                color: #9A3B5A;
            }
        }

        * {
            box-sizing: border-box;
            -webkit-print-color-adjust: exact !important;
            print-color-adjust: exact !important;
        }

        body {
            font-family: 'Cairo', 'Tajawal', 'Segoe UI', Tahoma, sans-serif;
            color: #2D2628;
            background-color: #FFFFFF;
            line-height: 1.65;
            font-size: 12.5px;
            margin: 0;
            padding: 0;
            direction: rtl;
        }

        /* Hero / Cover Card */
        .hero-banner {
            background: linear-gradient(135deg, #FFF0F3 0%, #FBE5E9 50%, #F5D3D9 100%);
            border: 2px solid #E8B4BE;
            border-radius: 18px;
            padding: 28px 24px;
            margin-bottom: 24px;
            text-align: center;
            box-shadow: 0 4px 12px rgba(154, 59, 90, 0.08);
        }

        .hero-logo {
            font-size: 38px;
            font-weight: 900;
            color: #9A3B5A;
            letter-spacing: -0.5px;
            margin: 0 0 4px 0;
        }

        .hero-subtitle {
            font-size: 15px;
            font-weight: 700;
            color: #5D2336;
            margin: 0 0 14px 0;
        }

        .hero-desc {
            font-size: 12px;
            color: #554447;
            max-width: 90%;
            margin: 0 auto 16px auto;
            line-height: 1.7;
        }

        .badge-bar {
            display: flex;
            justify-content: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .badge {
            background-color: #9A3B5A;
            color: #FFFFFF;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 10.5px;
            font-weight: 700;
            display: inline-block;
        }

        .badge-outline {
            background-color: #FFFFFF;
            color: #9A3B5A;
            border: 1.5px solid #9A3B5A;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 10.5px;
            font-weight: 700;
            display: inline-block;
        }

        /* Headings */
        h1, h2, h3, h4 {
            color: #9A3B5A;
            font-weight: 800;
            margin-top: 22px;
            margin-bottom: 10px;
        }

        h2 {
            font-size: 17px;
            border-bottom: 2px solid #F5D3D9;
            padding-bottom: 6px;
            display: flex;
            align-items: center;
            gap: 8px;
            page-break-after: avoid;
        }

        h3 {
            font-size: 14px;
            color: #7A2843;
            margin-top: 14px;
            margin-bottom: 6px;
            page-break-after: avoid;
        }

        /* Cards & Containers */
        .card {
            background: #FAFAFC;
            border: 1px solid #EFE4E6;
            border-radius: 12px;
            padding: 14px 16px;
            margin-bottom: 14px;
            page-break-inside: avoid;
        }

        .card-pink {
            background: #FFF7F8;
            border: 1.5px solid #F3CFD5;
            border-radius: 12px;
            padding: 14px 16px;
            margin-bottom: 14px;
            page-break-inside: avoid;
        }

        .card-callout {
            border-right: 4px solid #9A3B5A;
            background: #FFF5F7;
            padding: 12px 14px;
            border-radius: 0 10px 10px 0;
            margin: 12px 0;
            page-break-inside: avoid;
        }

        /* Tables */
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 14px 0;
            font-size: 11.5px;
            page-break-inside: avoid;
        }

        th {
            background-color: #9A3B5A;
            color: #FFFFFF;
            font-weight: 700;
            text-align: right;
            padding: 8px 10px;
            border: 1px solid #842A45;
        }

        td {
            padding: 8px 10px;
            border: 1px solid #EAD8DC;
            background-color: #FFFFFF;
        }

        tr:nth-child(even) td {
            background-color: #FDF9FA;
        }

        /* Lists */
        ul, ol {
            margin: 6px 0 12px 0;
            padding-right: 22px;
        }

        li {
            margin-bottom: 5px;
        }

        /* Code Blocks */
        pre {
            background: #24222A;
            color: #F8F8F2;
            padding: 12px;
            border-radius: 10px;
            font-family: 'Consolas', 'Courier New', monospace;
            font-size: 10.5px;
            direction: ltr;
            text-align: left;
            overflow-x: auto;
            page-break-inside: avoid;
            margin: 10px 0;
        }

        .grid-2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            page-break-inside: avoid;
        }

        .page-break {
            page-break-before: always;
        }

        .highlight {
            font-weight: 700;
            color: #9A3B5A;
        }

        .step-num {
            display: inline-block;
            background: #9A3B5A;
            color: #FFF;
            width: 22px;
            height: 22px;
            line-height: 22px;
            border-radius: 50%;
            text-align: center;
            font-size: 11px;
            font-weight: bold;
            margin-left: 6px;
        }
    </style>
</head>
<body>

    <!-- HERO HEADER -->
    <div class="hero-banner">
        <div class="hero-logo">🌸 لوميرا (LUMYRA)</div>
        <div class="hero-subtitle">المنظومة الرقمية والسريرية المتكاملة للاكتشاف المبكر لصحة الثدي والرعاية التفاعلية</div>
        <div class="hero-desc">
            وثيقة المشروع المرجعية الشاملة لفريق العمل (AI Engineers, Mobile/Flutter Developers, Backend Specialists, Clinical Advisors). تشرح رؤية المنصة، فلسفة التسمية، رحلات المستخدم، تفاصيل كل شاشة ووضع، المصادر الطبية العالمية المعتمدة، والمعمارية البرمجية للباك إند والفرونت إند.
        </div>
        <div class="badge-bar">
            <span class="badge">إصدار الفريق: 2.5.0-Production</span>
            <span class="badge">Google Gemini Multimodal AI</span>
            <span class="badge">Gail & Tyrer-Cuzick Models</span>
            <span class="badge">Flutter 3.x • NestJS • Prisma</span>
        </div>
    </div>

    <!-- SECTION 1 -->
    <h2>1️⃣ فكرة المشروع ورؤيته العامة (Project Vision & Philosophy)</h2>
    <div class="card-pink">
        <h3 style="margin-top:0;">🎯 المشكلة الطبية والاجتماعية في الوطن العربي ومصر:</h3>
        <p>يُعد سرطان الثدي أكثر أنواع الأورام شيوعاً بين السيدات عالمياً ومحلياً. وتثبت الإحصائيات الطبية الصادرة عن منظمة الصحة العالمية أن <strong>نسب الشفاء التام تتجاوز 90% في حال اكتشاف التغيرات النسيجية في المرحلتين المبكرتين (المرحلة 0 والمرحلة الأولى)</strong>.</p>
        <p>ورغم ذلك، تُشخص أكثر من 60% من الحالات في مراحل متقدمة نتيجة ثلاثة عوائق رئيسية:</p>
        <ul>
            <li><strong>حاجز الخوف والرهبة (Fear Barrier)</strong>: الخوف من الفحص، ورهبة المستشفيات، والمصطلحات الطبية الجافة.</li>
            <li><strong>تشتت الرعاية (Fragmented Healthcare)</strong>: انفصال نتائج الأشعة عن الاستشارات السريرية عن متابعة الأدوية ومراكز العلاج.</li>
            <li><strong>التشخيص العشوائي على الإنترنت</strong>: لجوء الكثيرات للمواقع العامة غير المتخصصة التي تنشر الذعر والهلع دون توجيه سريري معتمد.</li>
        </ul>
    </div>

    <div class="card">
        <h3 style="margin-top:0;">💡 الحل المبتكر الذي تقدمه "لوميرا":</h3>
        <p>بناء منظومة رقمية وسريرية ثلاثية الأطراف <strong>(المريضة + الطبيب الاستشاري + مسؤول الحوكمة الطبية)</strong> تقدم رعاية هادئة وموثوقة:</p>
        <ul>
            <li><strong>تحليل الأشعة بالذكاء الاصطناعي متعدد الوسائط (Gemini AI Vision)</strong> مع صمام أمان صارم يمنع التخمين الخاطئ.</li>
            <li><strong>تقييم المخاطر بمعايير إكلينيكية معتمدة</strong> (Gail Model & Tyrer-Cuzick Model) لتقدير نسب الـ 5 سنوات ومخاطر مدى الحياة.</li>
            <li><strong>وحدة تصوير ماموجرام متقدمة (DICOM Viewer)</strong> تتيح للطبيب فحص زوايا الأشعة وتكبير التكلسات النسيجية.</li>
            <li><strong>توجيه جغرافي لحظي بالـ GPS</strong> يربط السيدة فورياً بأقرب مركز فحص مجاني متخصص أو عيادة استشاري معتمد.</li>
        </ul>
    </div>

    <!-- SECTION 2 -->
    <h2>2️⃣ سر التسمية: لماذا "لوميرا" (LUMYRA)؟ وعلام يدل؟</h2>
    <p>تم استنباط الاسم وتصميمه ليجمع بين 3 دلالات لغوية ونفسية وطبية مقصودة:</p>
    <table>
        <thead>
            <tr>
                <th>الأصل والاشتقاق</th>
                <th>المعنى اللغوي</th>
                <th>الانعكاس العملي في تجربة المستخدم والمنصة</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><strong>Lumière</strong> (فرنسية / لاتينية)</td>
                <td>النور، الضياء، الإشراق والوضوح</td>
                <td><strong>نور المعرفة واليقين</strong> الذي يبدد عتمة الخوف من المجهول ويجعل خطوة الفحص المبكر واضحة ومطمئنة.</td>
            </tr>
            <tr>
                <td><strong>Amira / Mira</strong> (عربية / لاتينية)</td>
                <td>الأميرة، الأعجوبة، والسلام والسكينة</td>
                <td>معاملة كل سيدة تدخل المنصة بكرامة واحتواء كـ <strong>"أميرة"</strong> تحاط بالرعاية والاهتمام الهادئ.</td>
            </tr>
            <tr>
                <td><strong>Luminary</strong> (إنجليزية طبية)</td>
                <td>المرجع الهادي والمنارة الموثوقة</td>
                <td>منصة طبية مرجعية تلتزم بأعلى المعايير السريرية الدولية لتكون دليلاً استشارياً موثوقاً دون عشوائية.</td>
            </tr>
        </tbody>
    </table>

    <div class="card-callout">
        <strong>🎨 الهوية البصرية والألوان النفسية:</strong><br>
        تم استبعاد الألوان الباردة (مثل الأزرق الجاف أو الأبيض السريري) لما تسببه من ارتباط شرطي بغرف العمليات والمرض. واعتمدت المنصة ألواناً أنثوية مريحة نفسياً: درجات الورد الرقيق (<em>Soft Blush</em>)، مسحوق البودرة الدافئ (<em>Powder Rose</em>)، واللون العنابي الوقور (<em>Deep Burgundy</em>) لإضفاء شعور فوري بالدفء والأمان والوقار الطبي.
    </div>

    <div class="page-break"></div>

    <!-- SECTION 3 -->
    <h2>3️⃣ رحلة المستخدم الكاملة (The End-to-End User Journeys)</h2>

    <div class="card">
        <h3>👩‍🦰 أولاً: رحلة المريضة (Patient Journey)</h3>
        <ol>
            <li><strong>الاستقبال والاطمئنان</strong>: فتح التطبيق، اختيار اللغة (عربي/إنجليزي)، والاطلاع على التوعية المبسطة.</li>
            <li><strong>استبيان تقييم المخاطر الطبي الذكي</strong>: الإجابة على 5 مراحل دقيقة (العمر، الطمث، الإنجاب، العائلة، الخزعات، والفحص الذاتي).</li>
            <li><strong>استلام تقرير الخطورة الموثق</strong>: استعراض نسب الخطورة لـ 5 سنوات ومدى الحياة مع كود سريري مشفر لمشاركته مع الطبيب.</li>
            <li><strong>رفع وفحص الأشعة بـ Gemini AI</strong>: رفع صورة السونار أو الماموجرام لتحديد تصنيف الـ BI-RADS فورياً والتوصية السريرية.</li>
            <li><strong>اكتشاف أقرب مركز وعيادة عبر الـ GPS</strong>: فرز المراكز تلقائياً من الأقرب للأبعد بالكيلومتر مع زر اتصال مباشر وزر للمسار.</li>
            <li><strong>المتابعة العلاجية واليوميات</strong>: تسجيل جرعات العلاج الهرموني اليومي وتدوين الملاحظات والأعراض النفسية والجسدية.</li>
        </ol>
    </div>

    <div class="card">
        <h3>👨‍⚕️ ثانياً: رحلة الطبيب والاستشاري (Doctor Journey)</h3>
        <ol>
            <li><strong>التسجيل والتحقق المهني</strong>: تسجيل بيانات الطبيب ورقم ترخيص مزاولة المهنة المعتمد بوزارة الصحة.</li>
            <li><strong>التنبيهات السريرية الذكية (Smart Alerts)</strong>: لوحة تحكم تفرز الحالات الحرجة فوراً (مثل اشتباه ورمي BI-RADS 4B، أو تراجع التزام دوائي).</li>
            <li><strong>وحدة استعراض الماموجرام (DICOM Console)</strong>: فحص الأشعة بزواياها القياسية (L-CC, R-MLO, R-CC)، وتكبير التكلسات، وفحص صناديق الـ ROI.</li>
            <li><strong>إدارة الفحوصات والملف السريري</strong>: إعادة تسمية الفحوصات أو حذفها، وتدوين الملاحظات الطبية في ملف المريضة.</li>
            <li><strong>المحادثة السريرية المباشرة</strong>: مراسلة المريضات المتابعات وتوجيه الخطة العلاجية.</li>
            <li><strong>إضافة العيادة ونشر المقالات</strong>: تسجيل عيادته على الخريطة لتظهر للمريضات، ونشر مقالات موثوقة في نظام المحتوى التوعوي.</li>
        </ol>
    </div>

    <div class="card">
        <h3>🛠️ ثالثاً: رحلة مسؤول النظام (Admin Governance Journey)</h3>
        <ol>
            <li><strong>مراقبة المؤشرات الحية</strong>: متابعة أعداد المريضات، الأطباء، الفحوصات، والرسم البياني للنشاط الشهري.</li>
            <li><strong>اعتماد الأطباء الجدد</strong>: فحص تراخيص مزاولة المهنة ومستشفيات الانتماء والموافقة أو الرفض بلمسة واحدة.</li>
            <li><strong>حوكمة الحسابات</strong>: شاشة إدارة المستخدمين للبحث، التصفية، وتعطيل أو تفعيل أي حساب للمريضة أو الطبيب.</li>
            <li><strong>المساعد الذكي (AI Copilot)</strong>: محادثة ذكية مع Gemini لتحليل أداء المنظومة وتقديم اقتراحات تشغيلية دورية.</li>
            <li><strong>النسخ الاحتياطي المشفر</strong>: تصدير واستيراد بيانات المنصة بصيغة JSON منزوعة الهوية الشخصية (De-identified).</li>
        </ol>
    </div>

    <!-- SECTION 4 -->
    <h2>4️⃣ دليل الأوضاع والشاشات بالتفصيل (Screens & Modes Breakdown)</h2>

    <div class="grid-2">
        <div class="card-pink">
            <h3 style="margin-top:0;">🌸 وضع الزاهرة (Guest Mode)</h3>
            <p><strong>شاشة "اطمن على نفسك 🌸"</strong></p>
            <ul>
                <li>تتيح لأي زائرة إجراء الاستبيان السريع لتقييم المخاطر مجاناً بدون تسجيل حساب.</li>
                <li>تحديد العمر وأعراض الطمث والتاريخ العائلي وتلقي إرشاد سريري فوري مطمئن.</li>
            </ul>
        </div>
        <div class="card-pink">
            <h3 style="margin-top:0;">👩‍🦰 وضع المريضة: شاشة الرئيسية</h3>
            <p><strong>(Home Screen)</strong></p>
            <ul>
                <li>بطاقة الترحيب والاطمئنان اليومي وزر التبديل السريع بين الأدوار واللغات.</li>
                <li>متتبع الالتزام بالدواء (التاموكسيفين) ومواعيد الجرعات ونسبة الالتزام.</li>
                <li>المواعيد القادمة وبطاقات الوصول السريع للاستبيان ودليل المراكز.</li>
            </ul>
        </div>
    </div>

    <div class="grid-2">
        <div class="card">
            <h3 style="margin-top:0;">📊 شاشة استبيان تقييم المخاطر</h3>
            <p><strong>(Risk Assessment Screen)</strong></p>
            <ul>
                <li>5 مراحل سريرية تجمع التاريخ الهرموني، الإنجابي، العائلي، الخزعات، والفحص الذاتي.</li>
                <li>أزرار سريعة للأعمار (25، 35، 45 سنة...) وخانة إدخال رقمية مرنة.</li>
                <li>حساب فوري لمخاطر الـ 5 سنوات ومخاطر مدى الحياة (Gail & Tyrer-Cuzick).</li>
                <li>تجدد الاستبيان دورياً كل 30 يوماً للمتابعة المستمرة.</li>
            </ul>
        </div>
        <div class="card">
            <h3 style="margin-top:0;">🔬 شاشة رفع وفحص الأشعة</h3>
            <p><strong>(Scan Upload Dialog & Hub)</strong></p>
            <ul>
                <li>رفع صورة سونار، ماموجرام، رنين، أو تقرير عينات PDF.</li>
                <li>تحليل فوري بـ Gemini AI وتحديد نوع الفحص ودرجة الـ BI-RADS.</li>
                <li><strong>صمام أمان (Safety Guardrail)</strong>: إذا رُفعت صورة عادية يكتشفها النظام فوراً ويصنفها كـ <strong>"غير قاطع (Inconclusive)"</strong> دون أي تخمين مضلل.</li>
            </ul>
        </div>
    </div>

    <div class="grid-2">
        <div class="card-pink">
            <h3 style="margin-top:0;">📍 شاشة دليل المراكز والعيادات</h3>
            <p><strong>(Medical Centers Screen)</strong></p>
            <ul>
                <li>تحديد الموقع التلقائي عبر الـ GPS بنقرة واحدة.</li>
                <li>فرز المراكز والعيادات من الأقرب للأبعد بالكيلومتر لموقع المستخدمة.</li>
                <li>تصفية بين المستشفيات الكبرى (بهية ومعهد الأورام) وعيادات الأطباء المعتمدين.</li>
                <li>زر اتصال هاتفي مباشر وزر لرسم المسار والاتجاهات.</li>
            </ul>
        </div>
        <div class="card-pink">
            <h3 style="margin-top:0;">📖 شاشة اليوميات الصحية</h3>
            <p><strong>(Health Journal Screen)</strong></p>
            <ul>
                <li>تدوين الأعراض، مستويات الألم، والملاحظات اليومية.</li>
                <li>حفظ السجل الصحي التاريخي لمناقشته مع الطبيب المعالج في العيادة.</li>
            </ul>
        </div>
    </div>

    <div class="page-break"></div>

    <div class="card">
        <h3 style="margin-top:0;">👨‍⚕️ وضع الطبيب: لوحة التحكم والتنبيهات الذكية</h3>
        <p><strong>(Doctor Dashboard & Smart Alerts)</strong></p>
        <ul>
            <li><strong>شريط العمليات السريعة</strong>: تحليل أشعة (AI)، مراسلة المريضات، إضافة عيادة على الخريطة، ونشر مقال توعوي (CMS).</li>
            <li><strong>منظومة التنبيهات السريرية الذكية (Smart Alerts)</strong>: فرز المريضات آلياً حسب الأولوية:
                <ul>
                    <li>🔴 <strong style="color:#D32F2F;">حالة حرجة عاجلة</strong>: اشتباه شعاعي يستلزم خزعة موجهة (BI-RADS 4B).</li>
                    <li>🟡 <strong style="color:#F57C00;">أعراض تحذيرية</strong>: إفرازات حلمة دموية بالفحص الذاتي.</li>
                    <li>🔵 <strong style="color:#1976D2;">تراجع التزام دوائي</strong>: مريضة لم تسجل جرعة الدواء لـ 3 أيام متتالية.</li>
                </ul>
            </li>
            <li>أزرار سريعة بكل تنبيه: "مراسلة المريضة" أو "فتح الملف السريري".</li>
        </ul>
    </div>

    <div class="grid-2">
        <div class="card">
            <h3 style="margin-top:0;">🖥️ وحدة استعراض الماموجرام</h3>
            <p><strong>(DICOM Secondary Review Console)</strong></p>
            <ul>
                <li>عارض داكن احترافي بمحاكاة النسيج الليفي ومربع الآفة المشتبه بها (<code>ROI 1</code>).</li>
                <li>التبديل بين الزوايا المعتمدة عالمياً: <code>R-CC</code>, <code>R-MLO</code>, <code>L-CC</code>, و<code>مقارنة سابقة</code>.</li>
                <li>أدوات التكبير المجهري (Zoom)، وعكس التباين والألوان (Invert Contrast) لفحص التكلسات.</li>
                <li><strong>سجل التحليلات المحفوظة</strong>: استعراض الفحوصات مع إمكانية <strong>إعادة التسمية ✏️</strong> و<strong>الحذف 🗑️</strong>.</li>
            </ul>
        </div>
        <div class="card">
            <h3 style="margin-top:0;">📋 الملف السريري للمريضة</h3>
            <p><strong>(Patient Clinical Chart Screen)</strong></p>
            <ul>
                <li>بيانات المريضة، فصيلة الدم، والمرحلة الورمية (<code>Stage I ER+/PR+ HER2-</code>).</li>
                <li>نسبة الالتزام بالعلاج الهرموني وتاريخ آخر ماموجرام.</li>
                <li>كتابة وتوثيق الملاحظات السريرية وتحديث ملف المريضة فورياً.</li>
            </ul>
        </div>
    </div>

    <div class="grid-2">
        <div class="card-pink">
            <h3 style="margin-top:0;">🛠️ وضع الإدارة: لوحة القيادة</h3>
            <p><strong>(Admin Dashboard Screen)</strong></p>
            <ul>
                <li>إحصائيات حية: ١,٤٢٠ مريضة، ٤١ طبيباً، ٣,٨٤٠ فحصاً محللاً.</li>
                <li>رسم بياني تفاعلي لحجم الفحوصات الشهرية ومعدل الالتزام (92.4%).</li>
                <li>شريط الإجراءات: إدارة المستخدمين، المساعد الذكي، وتصدير نسخة احتياطية.</li>
            </ul>
        </div>
        <div class="card-pink">
            <h3 style="margin-top:0;">🛡️ مراجعة واعتماد تراخيص الأطباء</h3>
            <p><strong>(Doctor Verification Pipeline)</strong></p>
            <ul>
                <li>تدقيق رقم ترخيص مزاولة المهنة بوزارة الصحة واسم المستشفى.</li>
                <li>أزرار الموافقة والاعتماد أو الرفض لمنع انتحال الصفة الطبية.</li>
            </ul>
        </div>
    </div>

    <div class="grid-2">
        <div class="card">
            <h3 style="margin-top:0;">👥 إدارة المستخدمين الشاملة</h3>
            <p><strong>(User Governance Screen <code>/admin/users</code>)</strong></p>
            <ul>
                <li>بحث فوري بالاسم أو البريد وتصفية حسب الدور (أطباء / مريضات).</li>
                <li>زر فوري لـ "تعطيل الحساب / تفعيل الحساب".</li>
            </ul>
        </div>
        <div class="card">
            <h3 style="margin-top:0;">🤖 المساعد الذكي للإدارة</h3>
            <p><strong>(Admin AI Copilot Dialog)</strong></p>
            <ul>
                <li>محادثة ذكية مدعومة بـ Gemini لتقديم تقارير تشغيلية وتوصيات إدارية لتحسين أداء المنصة.</li>
            </ul>
        </div>
    </div>

    <!-- SECTION 5 -->
    <h2>5️⃣ المصادر والمراجع الطبية المعتمدة ومكانها في المشروع</h2>
    <table>
        <thead>
            <tr>
                <th style="width:28%;">المصدر الطبي المعتمد</th>
                <th style="width:28%;">ما هي هذه الهيئة؟</th>
                <th style="width:44%;">دوره وتطبيقه العملي داخل لوميرا (LUMYRA)</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><strong>المعهد القومي الأمريكي للسرطان<br>(NCI — National Cancer Institute)</strong></td>
                <td>أعلى مرجع حكومي وبحثي لعلاج وأبحاث الأورام في العالم.</td>
                <td>المطور الرسمي لأداة <strong>Gail Model (BCRAT)</strong>؛ نعتمد خوارزمياته لحساب مخاطر الإصابة بسرطان الثدي خلال 5 سنوات قادمة ومخاطر مدى الحياة عبر سن البلوغ، والولادة الأولى، وتاريخ الخزعات وإصابات الدرجة الأولى.</td>
            </tr>
            <tr>
                <td><strong>الكلية الأمريكية للأشعة<br>(ACR — American College of Radiology)</strong></td>
                <td>الهيئة المسؤولة عالمياً عن توحيد معايير وتفسير الأشعة التشخيصية.</td>
                <td>نطبق معيارها العالمي <strong>BI-RADS®</strong> في وحدة الذكاء الاصطناعي (Gemini Vision) وسجل الأشعة لتصنيف الفحوصات من السليم (<code>BI-RADS 1</code>) إلى المشتبه فيه والمستلزم لخزعة موجهة (<code>BI-RADS 4 & 5</code>).</td>
            </tr>
            <tr>
                <td><strong>شبكة السرطان الوطنية الشاملة<br>(NCCN Guidelines)</strong></td>
                <td>تحالف يضم 33 من كبرى مراكز السرطان العالمية يضع أدلة العلاج الإكلينيكي.</td>
                <td>نعتمد على <strong>NCCN Breast Screening Guidelines</strong> لتحديد عتبات الخطورة؛ ومتى يُنصح بالرنين المغناطيسي المتزامن مع الماموجرام (إذا تجاوز الخطر 20% مدى الحياة)، ومتى يُجرى الفحص الجيني لطفرات BRCA.</td>
            </tr>
            <tr>
                <td><strong>معهد وولفسون للطب الوقائي — جامعة كوين ماري لندن</strong></td>
                <td>المعهد البريطاني المطور لنماذج الخطورة العائلية والهرمونية الموسعة.</td>
                <td>نعتمد نموذج <strong>Tyrer-Cuzick Model (IBIS v8)</strong> لدمج عوامل متعددة الأجيال (الجدة، الخالات، العمات)، أورام المبيض، ومؤشر كتلة الجسم، والعلاج الهرموني التعويضي (HRT).</td>
            </tr>
            <tr>
                <td><strong>الجمعية الأمريكية والأوروبية لعلم الأورام (ASCO & ESMO)</strong></td>
                <td>أكبر جمعيتين عالميتين لجراحي وأطباء الأورام السريرية.</td>
                <td>نطبق بروتوكولاتهما في <strong>متابعة الالتزام بالعلاج الهرموني (Tamoxifen Adherence)</strong> وتنبيه الطبيب فورياً في حال انخفاض تناول الجرعات عن 80%.</td>
            </tr>
            <tr>
                <td><strong>مبادرة منظمة الصحة العالمية (WHO — GBCI)</strong></td>
                <td>المبادرة العالمية لسرطان الثدي لخفض الوفيات بنسبة 2.5% سنوياً.</td>
                <td>نطبق ركائزها الثلاث: التوعية الصحية، التشخيص المبكر للأعراض السريرية قبل بلوغ المرحلة الثانية، والإحالة السريعة لمراكز العلاج المعتمدة.</td>
            </tr>
            <tr>
                <td><strong>المبادرة الرئاسية لدعم صحة المرأة المصرية ومستشفى بهية ومعهد الأورام</strong></td>
                <td>البروتوكول القومي المصري للاكتشاف المبكر وسلسلة المراكز المتخصصة.</td>
                <td>تحديد سن الأربعين كبداية للماموجرام الروتيني، وتوجيه المريضات جغرافياً عبر الـ GPS لمستشفيات معتمدة مثل <strong>مؤسسة بهية (الهرم وزايد)</strong> و<strong>المعهد القومي للأورام</strong>.</td>
            </tr>
        </tbody>
    </table>

    <div class="page-break"></div>

    <!-- SECTION 6 -->
    <h2>6️⃣ المعمارية التقنية وتفاصيل الباك إند والفرونت إند</h2>

    <div class="grid-2">
        <div class="card">
            <h3 style="margin-top:0;">📱 الواجهات الأمامية (Flutter / Dart):</h3>
            <ul>
                <li><strong>إدارة الحالة (State Management)</strong>: <code>flutter_riverpod</code> لفصل منطق الأعمال والبيانات عن الواجهات بكفاءة.</li>
                <li><strong>التوجيه والتنقل (Routing)</strong>: <code>go_router</code> لدعم التوجيه العميق (Deep Linking) والتنقل السلس بين الأدوار.</li>
                <li><strong>تجاوب الشاشات والأبعاد (Responsive Layouts)</strong>: حل مشاكل الـ Overflow وتجاوز البكسل تماماً باستخدام <code>Wrap</code> و <code>Expanded</code> و <code>Flexible</code> لضمان مظهر مثالي على كافة أحجام شاشات الهواتف والتابلت.</li>
                <li><strong>دعم كامل للغة العربية (RTL-First)</strong>: تجربة عربية أصلية ومتناسقة مع إمكانية التبديل للإنجليزية بلمسة واحدة.</li>
                <li><strong>نظام التصميم المخصص (Design System)</strong>: لوحة ألوان دافئة تضم درجات الـ Blush والـ Rose والـ Burgundy مع مكونات موحدة (AppCard, PillButton, StatusBadge).</li>
            </ul>
        </div>
        <div class="card">
            <h3 style="margin-top:0;">⚙️ الخادم الخلفي (NestJS / TypeScript):</h3>
            <ul>
                <li><strong>الهيكلية النمطية (Modular Architecture)</strong>: تقسيم المنظومة إلى وحدات مستقلة (<code>ai</code>, <code>scans</code>, <code>risk-assessment</code>, <code>messages</code>, <code>doctors</code>, <code>medical-centers</code>, <code>admin</code>, <code>users</code>).</li>
                <li><strong>محرك الذكاء الاصطناعي متعدد الوسائط</strong>: الربط بـ <strong>Google Gemini API</strong> عبر سلسلة نماذج احتياطية (Fallback Chain):
                    <ol>
                        <li><code>gemini-3.5-flash-lite</code> (فائق السرعة للفحص والدردشة)</li>
                        <li><code>gemini-3.6-flash</code> (عالي الدقة لتحليل الصور الطبية)</li>
                        <li><code>gemini-3.5-flash</code> (احتياطي دائم لمنع أي توقف)</li>
                    </ol>
                </li>
                <li><strong>صمام الأمان للصور الطبية</strong>: فحص ذكي يكتشف الصور غير الطبية ويصنفها كـ <code>inconclusive</code> لمنع التخمين الخاطئ.</li>
                <li><strong>قاعدة البيانات والرقابة</strong>: <code>Prisma ORM</code> مع دعم العمل في وضع عدم الاتصال (Mock Fallback) وسجل تدقيق سريري مشفر (Audit Logging).</li>
            </ul>
        </div>
    </div>

    <!-- SECTION 7 -->
    <h2>7️⃣ البنية البرمجية وشجرة المجلدات (Project Structure)</h2>
    <pre>LUMYRA/
├── lib/                             # تطبيق الموبايل والويب (Flutter)
│   ├── app/                         # التهيئة، الثيمات، والتوجيه (GoRouter)
│   ├── core/                        # المكونات المشتركة، شبكة الاتصال، والتصميم
│   └── features/
│       ├── auth/                    # توثيق الحسابات والتبديل اللحظي بين الأدوار
│       ├── questionnaire/           # استبيان المخاطر ونماذج Gail & Tyrer-Cuzick
│       ├── doctor_dashboard/        # عارض DICOM، التنبيهات الذكية، والشات
│       ├── admin_dashboard/         # التحليلات الحية، إدارة المستخدمين، والـ Copilot
│       └── medical_centers/         # الدليل الجغرافي والفرز التلقائي عبر GPS
└── backend/                         # الخادم الخلفي المؤسسي (NestJS)
    └── src/
        ├── modules/
        │   ├── ai/                  # محرك Gemini للرؤية الحاسوبية والدردشة الطبية
        │   ├── scans/               # معالجة وحفظ وتعديل وحذف الفحوصات
        │   ├── risk-assessment/     # نماذج ومعايير تقييم الخطورة السريرية
        │   ├── messages/            # خدمة وتدفق الرسائل السريرية المباشرة
        │   ├── doctors/             # التنبيهات السريرية وإدارة عيادات الأطباء
        │   ├── medical-centers/     # خدمة المراكز الجغرافية والمسافات
        │   ├── educational/         # نظام إدارة المحتوى التوعوي (CMS)
        │   ├── admin/               # إحصائيات المنصة، Copilot، والنسخ الاحتياطي
        │   └── users/               # إدارة المستخدمين والصلاحيات
        └── common/                  # خدمات Prisma، الأمان، وسجل التدقيق (Audit)</pre>

    <!-- SECTION 8 -->
    <h2>8️⃣ دليل التشغيل السريع للمطورين (Quick Start Guide)</h2>
    <div class="card-pink">
        <h3 style="margin-top:0;">1. تشغيل الخادم الخلفي (Backend):</h3>
        <pre>cd backend
npm install
npm run build
npm run start</pre>
        <p><em>سيعمل الخادم محلياً على: <code>http://localhost:4000/api/v1</code></em></p>

        <h3>2. تشغيل تطبيق الهاتف (Mobile App):</h3>
        <pre>flutter pub get
flutter run</pre>

        <h3>3. رفع التحديثات إلى مستودع GitHub:</h3>
        <pre>git add .
git commit -m "docs: comprehensive team guide and production README"
git push origin main</pre>
    </div>

</body>
</html>
"""

with open("M:\\LUMYRA\\lumyra_team_guide.html", "w", encoding="utf-8") as f:
    f.write(html_content)

print("HTML generated successfully at M:\\LUMYRA\\lumyra_team_guide.html")
