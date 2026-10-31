import { Module } from '@nestjs/common';
import { MedicalCentersService } from './medical-centers.service';
import { MedicalCentersController } from './medical-centers.controller';

@Module({
  controllers: [MedicalCentersController],
  providers: [MedicalCentersService],
  exports: [MedicalCentersService],
})
export class MedicalCentersModule {}
