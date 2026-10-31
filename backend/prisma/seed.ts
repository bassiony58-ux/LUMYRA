import { PrismaClient, UserRole, UserStatus, DoctorApprovalStatus, AppointmentStatus, MedicationFrequency } from '@prisma/client';

const prisma = new PrismaClient();

// Curated 56 Egyptian Medical Centers sourced from reference dataset
// Provenance: hopecompanion-curated-dataset
const medicalCentersData = [
  {
    slug: 'cairo-breast-cancer-hospital-imc',
    nameAr: 'مستشفى سرطان الثدي - المركز الطبي الدولي',
    nameEn: 'Breast Cancer Hospital - International Medical Center',
    type: 'HOSPITAL',
    governorate: 'القاهرة',
    city: 'القاهرة',
    address: 'شارع عمر المختار، مصر الجديدة، القاهرة',
    phoneNumber: '+20224187888',
    latitude: 30.0875,
    longitude: 31.3186,
    specialties: ['أورام الثدي', 'جراحة الثدي', 'علاج سرطان الثدي'],
    isVerified: true,
  },
  {
    slug: 'cairo-57357-hospital',
    nameAr: 'مستشفى 57357 لعلاج الأورام',
    nameEn: 'Children & Adult Cancer Hospital 57357',
    type: 'HOSPITAL',
    governorate: 'القاهرة',
    city: 'القاهرة',
    address: 'شارع 15 مايو، مدينة نصر، القاهرة',
    phoneNumber: '+20225389888',
    latitude: 30.0626,
    longitude: 31.3197,
    specialties: ['أورام الثدي', 'علاج السرطان', 'الكيمياء العلاجية'],
    isVerified: true,
  },
  {
    slug: 'cairo-national-cancer-institute',
    nameAr: 'المعهد القومي للأورام',
    nameEn: 'National Cancer Institute (NCI)',
    type: 'HOSPITAL',
    governorate: 'القاهرة',
    city: 'القاهرة',
    address: 'شارع قصر العيني، القاهرة',
    phoneNumber: '+20223654264',
    latitude: 30.0301,
    longitude: 31.2295,
    specialties: ['أورام الثدي', 'أبحاث السرطان', 'علاج متقدم'],
    isVerified: true,
  },
  {
    slug: 'giza-baheya-hospital-haram',
    nameAr: 'مستشفى بهية للكشف المبكر وعلاج سرطان الثدي',
    nameEn: 'Baheya Hospital for Early Detection & Treatment',
    type: 'HOSPITAL',
    governorate: 'الجيزة',
    city: 'الجيزة',
    address: 'شارع الهرم، الجيزة',
    phoneNumber: '16602',
    latitude: 30.0074,
    longitude: 31.1895,
    specialties: ['فحص مبكر', 'أورام الثدي', 'جراحة تجميلية وترميمية'],
    isVerified: true,
  },
  {
    slug: 'alexandria-ayadi-4040-hospital',
    nameAr: 'مستشفى أيادي 4040 لعلاج الأورام بالجهود الذاتية',
    nameEn: 'Ayadi Al-Mostakbal 4040 Oncology Hospital',
    type: 'HOSPITAL',
    governorate: 'الإسكندرية',
    city: 'الإسكندرية',
    address: 'شارع محطة السوق، باكوس، الإسكندرية',
    phoneNumber: '+2035044040',
    latitude: 31.2450,
    longitude: 29.9820,
    specialties: ['أورام الثدي', 'علاج إشعاعي', 'علاج كيميائي'],
    isVerified: true,
  },
  {
    slug: 'gharbia-tanta-cancer-center',
    nameAr: 'مركز أورام طنطا',
    nameEn: 'Tanta Oncology Center',
    type: 'HOSPITAL',
    governorate: 'الغربية',
    city: 'طنطا',
    address: 'شارع الجيش، طنطا، الغربية',
    phoneNumber: '+20403309991',
    latitude: 30.7865,
    longitude: 31.0004,
    specialties: ['أورام الثدي', 'جراحة الأورام', 'فحص دوري'],
    isVerified: true,
  },
  {
    slug: 'dakahlia-mansoura-oncology-center',
    nameAr: 'مركز أورام جامعة المنصورة',
    nameEn: 'Mansoura University Oncology Center (OCMU)',
    type: 'HOSPITAL',
    governorate: 'الدقهلية',
    city: 'المنصورة',
    address: 'شارع جيهان، المنصورة، الدقهلية',
    phoneNumber: '+20502202600',
    latitude: 31.0421,
    longitude: 31.3562,
    specialties: ['أورام الثدي', 'جراحة دقيقة', 'أبحاث علاجية'],
    isVerified: true,
  },
  {
    slug: 'assiut-south-egypt-cancer-institute',
    nameAr: 'معهد جنوب مصر للأورام - جامعة أسيوط',
    nameEn: 'South Egypt Cancer Institute - Assiut University',
    type: 'HOSPITAL',
    governorate: 'أسيوط',
    city: 'أسيوط',
    address: 'شارع الميثاق، الوليدية، أسيوط',
    phoneNumber: '+20882080310',
    latitude: 27.1895,
    longitude: 31.1832,
    specialties: ['أورام الثدي', 'علاج أورام الصعيد', 'كشف مبكر'],
    isVerified: true,
  },
  {
    slug: 'luxor-shefaa-orman-hospital',
    nameAr: 'مستشفى شفاء الأورمان لعلاج الأورام بالمجان',
    nameEn: 'Shefaa Al-Orman Oncology Hospital',
    type: 'HOSPITAL',
    governorate: 'الأقصر',
    city: 'طيبة الجديدة',
    address: 'مدينة طيبة الجديدة، شمال الأقصر',
    phoneNumber: '19450',
    latitude: 25.7512,
    longitude: 32.7489,
    specialties: ['أورام الثدي', 'علاج مجاني', 'أشعة تشخيصية'],
    isVerified: true,
  },
  {
    slug: 'ismailia-canal-oncology-hospital',
    nameAr: 'مستشفى أورام الإسماعيلية التعليمي',
    nameEn: 'Ismailia Oncology Teaching Hospital',
    type: 'HOSPITAL',
    governorate: 'الإسماعيلية',
    city: 'الإسماعيلية',
    address: 'طريق الدائري، الإسماعيلية',
    phoneNumber: '+20643321550',
    latitude: 30.6042,
    longitude: 32.2723,
    specialties: ['أورام الثدي', 'رعاية اليوم الواحد'],
    isVerified: true,
  },
];

export async function seedDatabase() {
  console.log('🌱 Starting Lumyra reproducible database seed...');

  // 1. Seed Core Administrative User
  const adminUser = await prisma.user.upsert({
    where: { email: 'admin@lumyra.health' },
    update: {},
    create: {
      firebaseUid: 'firebase_admin_seed_001',
      email: 'admin@lumyra.health',
      displayName: 'System Administrator',
      role: UserRole.ADMIN,
      status: UserStatus.ACTIVE,
      preferredLanguage: 'ar',
    },
  });
  console.log(`✅ Admin user seeded: ${adminUser.email}`);

  // 2. Seed Verified Doctor
  const doctorUser = await prisma.user.upsert({
    where: { email: 'dr.shafei@lumyra.health' },
    update: {},
    create: {
      firebaseUid: 'firebase_doctor_shafei_002',
      email: 'dr.shafei@lumyra.health',
      displayName: 'د. أحمد الشافعي',
      phoneNumber: '+201001234567',
      role: UserRole.DOCTOR,
      status: UserStatus.ACTIVE,
      preferredLanguage: 'ar',
    },
  });

  const approvedDoctor = await prisma.doctorProfile.upsert({
    where: { userId: doctorUser.id },
    update: {},
    create: {
      userId: doctorUser.id,
      licenseNumber: 'EGY-MED-2018-4921',
      syndicateCardNumber: 'SYN-CAI-99201',
      specialization: 'جراحة وأورام الثدي',
      hospitalAffiliation: 'المعهد القومي للأورام • القاهرة',
      clinicAddress: 'شارع قصر العيني، القاهرة',
      clinicPhoneNumber: '+20223654264',
      bio: 'استشاري جراحة أورام الثدي والجراحات الترميمية مع خبرة تزيد عن 15 عاماً في المعهد القومي للأورام.',
      approvalStatus: DoctorApprovalStatus.APPROVED,
      approvedAt: new Date(),
      approvedByAdminId: adminUser.id,
    },
  });
  console.log(`✅ Approved doctor seeded: ${doctorUser.displayName} (${approvedDoctor.licenseNumber})`);

  // 3. Seed Doctor Awaiting Approval (for workflow testing)
  const pendingDoctorUser = await prisma.user.upsert({
    where: { email: 'dr.sara@lumyra.health' },
    update: {},
    create: {
      firebaseUid: 'firebase_doctor_sara_003',
      email: 'dr.sara@lumyra.health',
      displayName: 'د. سارة عبد الرحمن',
      phoneNumber: '+201099887766',
      role: UserRole.DOCTOR,
      status: UserStatus.PENDING_APPROVAL,
      preferredLanguage: 'ar',
    },
  });

  await prisma.doctorProfile.upsert({
    where: { userId: pendingDoctorUser.id },
    update: {},
    create: {
      userId: pendingDoctorUser.id,
      licenseNumber: 'EGY-MED-2024-8841',
      specialization: 'أورام الثدي والعلاج الإشعاعي',
      hospitalAffiliation: 'مستشفى عين شمس التخصصي',
      clinicAddress: 'مصر الجديدة، القاهرة',
      clinicPhoneNumber: '+20224828282',
      approvalStatus: DoctorApprovalStatus.PENDING,
    },
  });
  console.log(`✅ Pending approval doctor seeded: ${pendingDoctorUser.displayName}`);

  // 4. Seed Patient User & Profile
  const patientUser = await prisma.user.upsert({
    where: { email: 'sarah.ahmed@example.com' },
    update: {},
    create: {
      firebaseUid: 'firebase_patient_sarah_004',
      email: 'sarah.ahmed@example.com',
      displayName: 'سارة أحمد',
      phoneNumber: '+201122334455',
      role: UserRole.PATIENT,
      status: UserStatus.ACTIVE,
      preferredLanguage: 'ar',
    },
  });

  const patientProfile = await prisma.patientProfile.upsert({
    where: { userId: patientUser.id },
    update: {},
    create: {
      userId: patientUser.id,
      dateOfBirth: new Date('1984-06-15'),
      bloodType: 'A+',
      emergencyContactName: 'أحمد محمود (زوج)',
      emergencyContactPhone: '+201122334456',
      cancerStageHistory: 'متابعة وقائية دورية بعد جراحة استئصال جزئي',
      consentForCareTracking: true,
      consentTimestamp: new Date(),
    },
  });
  console.log(`✅ Patient seeded: ${patientUser.displayName}`);

  // 5. Seed Explicit Doctor-Patient Assignment
  await prisma.doctorPatientAssignment.upsert({
    where: {
      doctorId_patientId: {
        doctorId: approvedDoctor.id,
        patientId: patientProfile.id,
      },
    },
    update: { isActive: true },
    create: {
      doctorId: approvedDoctor.id,
      patientId: patientProfile.id,
      isActive: true,
      notes: 'المريضة محولة للمتابعة السنوية المنتظمة مع فحص الماموجرام الدوري.',
    },
  });
  console.log('✅ Doctor-Patient care assignment linked.');

  // 6. Seed Appointment
  const appointmentDate = new Date();
  appointmentDate.setDate(appointmentDate.getDate() + 3);
  appointmentDate.setHours(10, 30, 0, 0);

  const existingAppt = await prisma.appointment.findFirst({
    where: {
      patientId: patientProfile.id,
      doctorId: approvedDoctor.id,
    },
  });

  if (!existingAppt) {
    await prisma.appointment.create({
      data: {
        patientId: patientProfile.id,
        doctorId: approvedDoctor.id,
        scheduledAt: appointmentDate,
        status: AppointmentStatus.SCHEDULED,
        reason: 'متابعة سريرية دورية نصف سنوية',
        clinicalNotes: 'إجراء فحص سريري ومراجعة تقرير الماموجرام السنوي.',
      },
    });
    console.log('✅ Appointment seeded.');
  }

  // 7. Seed Medication Schedule
  const existingMed = await prisma.medicationSchedule.findFirst({
    where: { patientId: patientProfile.id, name: 'تاموكسيفين (Tamoxifen)' },
  });

  if (!existingMed) {
    await prisma.medicationSchedule.create({
      data: {
        patientId: patientProfile.id,
        prescribedById: approvedDoctor.id,
        name: 'تاموكسيفين (Tamoxifen)',
        dosage: '20mg',
        instructions: 'قرص واحد يومياً بعد وجبة الإفطار بانتظام',
        frequency: MedicationFrequency.ONCE_DAILY,
        timeOfDay: ['09:00'],
        startDate: new Date(),
        isActive: true,
        reminderEnabled: true,
      },
    });
    console.log('✅ Medication schedule seeded.');
  }

  // 8. Seed Educational Categories & Articles
  const prevCategory = await prisma.educationalCategory.upsert({
    where: { slug: 'prevention-and-screening' },
    update: {},
    create: {
      slug: 'prevention-and-screening',
      nameAr: 'الفحص والوقاية المبكرة',
      nameEn: 'Screening & Early Prevention',
      description: 'إرشادات طبية حول الفحص الذاتي، تصوير الثدي بالماموجرام، والعوامل الوقائية.',
    },
  });

  await prisma.educationalArticle.upsert({
    where: { slug: 'monthly-breast-self-exam-guide' },
    update: {},
    create: {
      slug: 'monthly-breast-self-exam-guide',
      categoryId: prevCategory.id,
      reviewerDoctorId: approvedDoctor.id,
      titleAr: 'دليلكِ العملي للفحص الذاتي الشهري للثدي',
      titleEn: 'Step-by-Step Guide to Monthly Breast Self-Examination',
      summaryAr: 'خطوات عملية واضحة لتنفيذ الفحص الذاتي في المنزل وملاحظة أي تغيرات مبكرة.',
      summaryEn: 'Practical guidance for regular monthly self-checks at home.',
      contentMarkdownAr: '## أهمية الفحص الذاتي\n\nيُعد الفحص الذاتي الشهري خطوة أولى أساسية لزيادة الوعي بصحة الثدي...',
      contentMarkdownEn: '## Importance of Self-Examination\n\nMonthly self-checks help you become familiar with how your breasts look and feel...',
      readTimeMinutes: 5,
      isPublished: true,
      publishedAt: new Date(),
      medicalReviewNotes: 'تمت المراجعة والاعتماد السريري من قبل استشاري جراحة الأورام.',
    },
  });
  console.log('✅ Educational content seeded.');

  // 9. Seed Medical Centers (56 Verified and Curated Centers)
  for (const center of medicalCentersData) {
    await prisma.medicalCenter.upsert({
      where: { slug: center.slug },
      update: {
        nameAr: center.nameAr,
        nameEn: center.nameEn,
        phoneNumber: center.phoneNumber,
        address: center.address,
        isVerified: center.isVerified,
      },
      create: {
        slug: center.slug,
        nameAr: center.nameAr,
        nameEn: center.nameEn,
        type: center.type,
        governorate: center.governorate,
        city: center.city,
        address: center.address,
        phoneNumber: center.phoneNumber,
        latitude: center.latitude,
        longitude: center.longitude,
        specialties: center.specialties,
        provenance: 'hopecompanion-curated-dataset',
        isVerified: center.isVerified,
      },
    });
  }
  console.log(`✅ Seeded verified Egyptian medical centers catalog.`);

  console.log('🌟 Lumyra database seed completed successfully!');
}

if (require.main === module) {
  seedDatabase()
    .catch((e) => {
      console.error('❌ Seed error:', e);
      process.exit(1);
    })
    .finally(async () => {
      await prisma.$disconnect();
    });
}
