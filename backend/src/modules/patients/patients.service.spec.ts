import { NotFoundException, ForbiddenException } from '@nestjs/common';
import { PatientsService } from './patients.service';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { AccessControlService } from '../../common/services/access-control.service';
import { AuthenticatedUser, UserRole, UserStatus } from '../../common/interfaces/authenticated-user.interface';

describe('PatientsService', () => {
  let service: PatientsService;
  let mockPrisma: any;
  let mockAudit: any;
  let mockAccessControl: any;

  const samplePatientUser: AuthenticatedUser = {
    id: 'user-pat-01',
    firebaseUid: 'uid-pat-01',
    email: 'mariam@lumyra.health',
    displayName: 'Mariam Ali',
    role: UserRole.PATIENT,
    status: UserStatus.ACTIVE,
    isActive: true,
    patientProfileId: 'profile-pat-01',
  };

  beforeEach(() => {
    process.env.SKIP_DB_CONNECT = 'false';

    mockPrisma = {
      patientProfile: {
        findUnique: jest.fn(),
        update: jest.fn(),
      },
      educationalArticle: {
        findMany: jest.fn(),
      },
      doctorPatientAssignment: {
        findUnique: jest.fn(),
        upsert: jest.fn(),
        update: jest.fn(),
      },
    };

    mockAudit = {
      logEvent: jest.fn(),
    };

    mockAccessControl = {
      assertPatientAccess: jest.fn(),
    };

    service = new PatientsService(
      mockPrisma as PrismaService,
      mockAudit as AuditService,
      mockAccessControl as AccessControlService,
    );
  });

  describe('getMyDashboard', () => {
    it('should throw NotFoundException if patientProfileId is missing', async () => {
      const userWithoutProfile = { ...samplePatientUser, patientProfileId: undefined };
      await expect(service.getMyDashboard(userWithoutProfile as any)).rejects.toThrow(
        NotFoundException,
      );
    });

    it('should retrieve aggregated dashboard data with appointments, medications, and articles', async () => {
      mockPrisma.patientProfile.findUnique.mockResolvedValue({
        id: 'profile-pat-01',
        consentForCareTracking: true,
        user: {
          displayName: 'Mariam Ali',
          email: 'mariam@lumyra.health',
          preferredLanguage: 'ar',
        },
        doctorAssignments: [
          {
            doctorId: 'doc-nour-01',
            doctor: {
              specialization: 'Oncology',
              hospitalAffiliation: 'National Cancer Institute',
              clinicAddress: 'Cairo',
              user: { displayName: 'Dr. Nour El-Din', email: 'nour@lumyra.health' },
            },
          },
        ],
        medications: [
          {
            id: 'med-01',
            name: 'Tamoxifen',
            dosage: '20 mg',
            instructions: 'Take with water after breakfast',
            frequency: 'ONCE_DAILY',
            timeOfDay: ['09:00'],
            startDate: new Date('2026-10-01'),
            endDate: null,
          },
        ],
        appointments: [
          {
            id: 'appt-01',
            scheduledAt: new Date('2026-11-01T10:00:00Z'),
            estimatedDurationMinutes: 30,
            status: 'SCHEDULED',
            reason: 'Routine post-screening clinical evaluation',
            doctor: {
              specialization: 'Oncology',
              user: { displayName: 'Dr. Nour El-Din' },
            },
          },
        ],
      });

      mockPrisma.educationalArticle.findMany.mockResolvedValue([
        {
          id: 'art-01',
          slug: 'monthly-breast-self-exam-guide',
          titleAr: 'دليلك الشامل للفحص الذاتي',
          titleEn: 'Monthly Breast Self-Exam Guide',
          summaryAr: 'دليل الفحص الشهري',
          summaryEn: 'Guide to monthly exams',
          category: { nameAr: 'الفحص الذاتي والتوعية', nameEn: 'Self-Examination' },
          readTimeMinutes: 5,
        },
      ]);

      const dashboard = await service.getMyDashboard(samplePatientUser);

      expect(dashboard.profile.displayName).toBe('Mariam Ali');
      expect(dashboard.upcomingAppointments).toHaveLength(1);
      expect(dashboard.upcomingAppointments[0].doctorName).toBe('Dr. Nour El-Din');
      expect(dashboard.activeMedications).toHaveLength(1);
      expect(dashboard.activeMedications[0].name).toBe('Tamoxifen');
      expect(dashboard.recommendedArticles).toHaveLength(1);
      expect(dashboard.careTeam).toHaveLength(1);
      expect(dashboard.careTeam[0].doctorName).toBe('Dr. Nour El-Din');
    });
  });

  describe('getPatientById - Isolation & Access Control', () => {
    it('should invoke AccessControlService and throw if cross-patient access is attempted', async () => {
      mockAccessControl.assertPatientAccess.mockRejectedValue(
        new ForbiddenException('Access denied: You are not authorized to access another patient’s clinical records.'),
      );

      await expect(service.getPatientById('foreign-profile-999', samplePatientUser)).rejects.toThrow(
        ForbiddenException,
      );
      expect(mockAccessControl.assertPatientAccess).toHaveBeenCalledWith(
        samplePatientUser,
        'foreign-profile-999',
      );
    });
  });
});
