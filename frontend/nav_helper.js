/**
 * Lumyra Stitch Navigation & API Integration Helper
 * Provides seamless cross-screen routing, role state, and live backend connection
 */
(function() {
  // Routes Mapping for all 17 Stitch Screens
  const ROUTES = {
    welcome: '../screen_1_welcome_splash/code.html',
    role_selection: '../screen_2_role_selection/code.html',
    login: '../screen_3_sign_in_quick_switcher/code.html',
    patient_home: '../screen_4_patient_home_dashboard/code.html',
    questionnaire: '../screen_5_guided_breast_health_questionnaire/code.html',
    journal: '../screen_6_private_health_mood_journal/code.html',
    medications: '../screen_7_medication_adherence_schedule_tracker/code.html',
    appointments: '../screen_8_appointments_consultation_booking/code.html',
    education: '../screen_9_educational_library_breast_health_articles/code.html',
    centers: '../screen_10_verified_medical_center_directory/code.html',
    ai_assistant: '../screen_11_conversational_ai_health_assistant/code.html',
    doctor_home: '../screen_12_doctor_workspace_dashboard/code.html',
    doctor_chart: '../screen_13_patient_clinical_chart_overview/code.html',
    doctor_imaging: '../screen_14_secondary_medical_imaging_viewer/code.html',
    admin_home: '../screen_15_admin_governance_dashboard/code.html',
    admin_approvals: '../screen_16_admin_doctor_license_verification_pipeline/code.html',
    admin_audit: '../screen_17_admin_security_hipaa_gdpr_audit_logs/code.html',
  };

  window.LUMYRA_ROUTES = ROUTES;

  // Initialize on DOM ready
  document.addEventListener('DOMContentLoaded', () => {
    wireNavigation();
    wireBottomNav();
    // Floating helper bar removed per user request
  });

  function wireNavigation() {
    // Screen 1: Welcome CTA buttons
    const startBtn = document.getElementById('start-journey-btn');
    if (startBtn) {
      startBtn.addEventListener('click', () => {
        window.location.href = ROUTES.role_selection;
      });
    }

    const loginBtn = document.getElementById('login-btn');
    if (loginBtn) {
      loginBtn.addEventListener('click', () => {
        window.location.href = ROUTES.login;
      });
    }

    // Screen 2: Role selection submit
    const submitRoleBtn = document.getElementById('submit-role-btn');
    if (submitRoleBtn) {
      submitRoleBtn.addEventListener('click', () => {
        const activeCard = document.querySelector('.role-card.ring-primary');
        const role = activeCard ? activeCard.getAttribute('data-role') : 'patient';
        sessionStorage.setItem('lumyra_role', role);
        if (role === 'doctor') {
          window.location.href = ROUTES.doctor_home;
        } else if (role === 'admin') {
          window.location.href = ROUTES.admin_home;
        } else {
          window.location.href = ROUTES.patient_home;
        }
      });
    }

    // Screen 3: Login form submission and quick role fills
    const loginForm = document.querySelector('form');
    if (loginForm && window.location.href.includes('screen_3')) {
      loginForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const email = document.getElementById('emailInput')?.value || '';
        if (email.includes('doctor')) {
          sessionStorage.setItem('lumyra_role', 'doctor');
          window.location.href = ROUTES.doctor_home;
        } else if (email.includes('admin')) {
          sessionStorage.setItem('lumyra_role', 'admin');
          window.location.href = ROUTES.admin_home;
        } else {
          sessionStorage.setItem('lumyra_role', 'patient');
          window.location.href = ROUTES.patient_home;
        }
      });
    }

    // Logo click in any header navigates to role home
    document.querySelectorAll('header img[alt*="Logo"], header span:contains("لوميرا")').forEach(el => {
      el.style.cursor = 'pointer';
      el.addEventListener('click', () => {
        const role = sessionStorage.getItem('lumyra_role') || 'patient';
        if (role === 'doctor') window.location.href = ROUTES.doctor_home;
        else if (role === 'admin') window.location.href = ROUTES.admin_home;
        else window.location.href = ROUTES.patient_home;
      });
    });

    // Language switchers
    const langSwitch = document.getElementById('lang-switch-btn') || document.querySelector('.lang-btn');
    if (langSwitch) {
      langSwitch.addEventListener('click', () => {
        const isRtl = document.documentElement.getAttribute('dir') === 'rtl';
        document.documentElement.setAttribute('dir', isRtl ? 'ltr' : 'rtl');
        document.documentElement.setAttribute('lang', isRtl ? 'en' : 'ar');
      });
    }
  }

  function wireBottomNav() {
    // Bottom Nav anchors with data-path
    document.querySelectorAll('nav a[data-path]').forEach(link => {
      link.addEventListener('click', (e) => {
        e.preventDefault();
        const path = link.getAttribute('data-path');
        switch (path) {
          case 'home':
            window.location.href = ROUTES.patient_home;
            break;
          case 'intake':
          case 'questionnaire':
            window.location.href = ROUTES.questionnaire;
            break;
          case 'journal':
            window.location.href = ROUTES.journal;
            break;
          case 'care':
          case 'medications':
            window.location.href = ROUTES.medications;
            break;
          case 'appointments':
            window.location.href = ROUTES.appointments;
            break;
          case 'education':
            window.location.href = ROUTES.education;
            break;
          case 'centers':
            window.location.href = ROUTES.centers;
            break;
          case 'ai-assistant':
            window.location.href = ROUTES.ai_assistant;
            break;
          case 'clinic-cohort':
            window.location.href = ROUTES.doctor_home;
            break;
          case 'clinical-chart':
            window.location.href = ROUTES.doctor_chart;
            break;
          case 'imaging-dicom':
            window.location.href = ROUTES.doctor_imaging;
            break;
          case 'governance-admin':
            window.location.href = ROUTES.admin_home;
            break;
          case 'settings':
            window.location.href = ROUTES.admin_audit;
            break;
        }
      });
    });
  }

  // Floating Hub Bar for rapid testing across all 17 screens
  function injectFloatingHelper() {
    if (window.top !== window.self) return; // Don't inject if embedded in iframe
    if (document.getElementById('lumyra-tester-bar')) return;

    const bar = document.createElement('div');
    bar.id = 'lumyra-tester-bar';
    bar.style.cssText = `
      position: fixed;
      top: 6px;
      right: 12px;
      z-index: 99999;
      background: rgba(33, 25, 30, 0.92);
      backdrop-filter: blur(12px);
      color: #fff;
      padding: 6px 12px;
      border-radius: 9999px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.3);
      font-family: 'Cairo', system-ui, sans-serif;
      font-size: 12px;
      display: flex;
      align-items: center;
      gap: 8px;
      direction: rtl;
    `;

    bar.innerHTML = `
      <span style="display:flex; align-items:center; gap:4px; font-weight:700; color:#F2808F;">
        <span style="font-size:14px;">🌸</span> لوميرا
      </span>
      <select id="lumyra-screen-select" style="
        background: #2D2327;
        color: #fff;
        border: 1px solid #7B5459;
        border-radius: 9999px;
        padding: 3px 8px;
        font-size: 11px;
        outline: none;
        cursor: pointer;
      ">
        <option value="" disabled selected>تصفح الشاشات (١٧ شاشة) ▾</option>
        <optgroup label="البداية والمصادقة">
          <option value="${ROUTES.welcome}">١. الترحيب (Welcome & Splash)</option>
          <option value="${ROUTES.role_selection}">٢. اختيار الدور (Role Selection)</option>
          <option value="${ROUTES.login}">٣. تسجيل الدخول (Sign In)</option>
        </optgroup>
        <optgroup label="مسار المريضة">
          <option value="${ROUTES.patient_home}">٤. الرئيسية للمريضة (Patient Dashboard)</option>
          <option value="${ROUTES.questionnaire}">٥. استبيان صحة الثدي (Questionnaire)</option>
          <option value="${ROUTES.journal}">٦. سجل اليوميات والأعراض (Journal)</option>
          <option value="${ROUTES.medications}">٧. جدول الأدوية (Medications)</option>
          <option value="${ROUTES.appointments}">٨. حجز المواعيد (Appointments)</option>
          <option value="${ROUTES.education}">٩. مكتبة المقالات (Education)</option>
          <option value="${ROUTES.centers}">١٠. دليل المراكز الطبية (Centers)</option>
          <option value="${ROUTES.ai_assistant}">١١. المساعد الذكي شات بوت (AI Assistant)</option>
        </optgroup>
        <optgroup label="مسار الطبيب">
          <option value="${ROUTES.doctor_home}">١٢. لوحة تحكم الطبيب (Doctor Workspace)</option>
          <option value="${ROUTES.doctor_chart}">١٣. الملف الطبي للمريضة (Patient Chart)</option>
          <option value="${ROUTES.doctor_imaging}">١٤. عارض الأشعة DICOM (Imaging Viewer)</option>
        </optgroup>
        <optgroup label="مسار الإدارة">
          <option value="${ROUTES.admin_home}">١٥. لوحة الإدارة (Admin Dashboard)</option>
          <option value="${ROUTES.admin_approvals}">١٦. اعتماد تراخيص الأطباء (Doctor Approvals)</option>
          <option value="${ROUTES.admin_audit}">١٧. سجلات الأمان والتدقيق (Audit Logs)</option>
        </optgroup>
      </select>
      <button id="lumyra-toggle-dir" style="
        background: transparent;
        border: 1px solid #7B5459;
        color: #fff;
        border-radius: 9999px;
        padding: 2px 8px;
        font-size: 10px;
        cursor: pointer;
      ">عربي / EN</button>
    `;

    document.body.appendChild(bar);

    document.getElementById('lumyra-screen-select').addEventListener('change', (e) => {
      if (e.target.value) window.location.href = e.target.value;
    });

    document.getElementById('lumyra-toggle-dir').addEventListener('click', () => {
      const isRtl = document.documentElement.getAttribute('dir') === 'rtl';
      document.documentElement.setAttribute('dir', isRtl ? 'ltr' : 'rtl');
      document.documentElement.setAttribute('lang', isRtl ? 'en' : 'ar');
    });
  }
})();
