import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { CommonModule } from './common/common.module';
import { AuditModule } from './modules/audit/audit.module';
import { HealthModule } from './modules/health/health.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { PatientsModule } from './modules/patients/patients.module';
import { DoctorsModule } from './modules/doctors/doctors.module';
import { MedicalCentersModule } from './modules/medical-centers/medical-centers.module';
import { AppointmentsModule } from './modules/appointments/appointments.module';
import { ScansModule } from './modules/scans/scans.module';
import { JournalsModule } from './modules/journals/journals.module';
import { MedicationsModule } from './modules/medications/medications.module';
import { EducationalModule } from './modules/educational/educational.module';
import { AiModule } from './modules/ai/ai.module';
import { RiskAssessmentModule } from './modules/risk-assessment/risk-assessment.module';
import { MessagesModule } from './modules/messages/messages.module';
import { AdminModule } from './modules/admin/admin.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    CommonModule,
    AuditModule,
    HealthModule,
    AuthModule,
    UsersModule,
    PatientsModule,
    DoctorsModule,
    MedicalCentersModule,
    AppointmentsModule,
    ScansModule,
    JournalsModule,
    MedicationsModule,
    EducationalModule,
    AiModule,
    RiskAssessmentModule,
    MessagesModule,
    AdminModule,
  ],
})
export class AppModule {}
