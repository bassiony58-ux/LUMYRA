import { Global, Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { StorageModule } from './storage/storage.module';
import { AccessControlService } from './services/access-control.service';

@Global()
@Module({
  imports: [PrismaModule, StorageModule],
  providers: [AccessControlService],
  exports: [PrismaModule, StorageModule, AccessControlService],
})
export class CommonModule {}
