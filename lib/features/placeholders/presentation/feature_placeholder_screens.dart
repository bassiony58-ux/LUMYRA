import '../../education/presentation/education_screen.dart';
import '../../journal/presentation/journal_screen.dart';
import '../../medications/presentation/medication_tracker_screen.dart';
import '../../appointments/presentation/appointments_screen.dart';
import '../../medical_centers/presentation/medical_centers_screen.dart';
import '../../ai_assistant/presentation/ai_assistant_screen.dart';
import '../../doctor_dashboard/presentation/patient_chart_screen.dart';
import '../../doctor_dashboard/presentation/imaging_viewer_screen.dart';
import '../../admin_dashboard/presentation/doctor_approvals_screen.dart';
import '../../admin_dashboard/presentation/audit_logs_screen.dart';
import '../../questionnaire/presentation/questionnaire_screen.dart';

/// Aliases and backward-compatible screen exports wired directly to the real feature screens
typedef EducationPlaceholderScreen = EducationScreen;
typedef JournalPlaceholderScreen = JournalScreen;
typedef CarePlaceholderScreen = MedicationTrackerScreen;
typedef AppointmentsPlaceholderScreen = AppointmentsScreen;
typedef MedicalCentersPlaceholderScreen = MedicalCentersScreen;
typedef AiAssistantPlaceholderScreen = AiAssistantScreen;
typedef DoctorPatientsPlaceholderScreen = PatientChartScreen;
typedef DoctorImagingPlaceholderScreen = ImagingViewerScreen;
typedef AdminApprovalsPlaceholderScreen = DoctorApprovalsScreen;
typedef AdminAnalyticsPlaceholderScreen = AuditLogsScreen;
typedef RiskAssessmentPlaceholderScreen = QuestionnaireScreen;
