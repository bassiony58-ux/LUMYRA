import { Module, Global } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { FirebaseAdminService } from './firebase-admin.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { DoctorApprovedGuard } from '../../common/guards/doctor-approved.guard';

@Global()
@Module({
  controllers: [AuthController],
  providers: [
    AuthService,
    FirebaseAdminService,
    FirebaseAuthGuard,
    RolesGuard,
    DoctorApprovedGuard,
  ],
  exports: [
    AuthService,
    FirebaseAdminService,
    FirebaseAuthGuard,
    RolesGuard,
    DoctorApprovedGuard,
  ],
})
export class AuthModule {}
