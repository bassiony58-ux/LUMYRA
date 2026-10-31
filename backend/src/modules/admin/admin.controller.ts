import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { AdminService } from './admin.service';
import { AdminCopilotDto } from './dto/admin-copilot.dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuthenticatedUser, UserRole } from '../../common/interfaces/authenticated-user.interface';

@Controller('admin')
@UseGuards(FirebaseAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('analytics')
  async getAnalytics() {
    return this.adminService.getAnalytics();
  }

  @Post('copilot')
  async runCopilot(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: AdminCopilotDto,
  ) {
    return this.adminService.runAdminCopilot(dto.query, user);
  }

  @Get('export')
  async exportData() {
    return this.adminService.exportPlatformData();
  }

  @Post('import')
  async importData(@Body() payload: any) {
    return this.adminService.importData(payload);
  }
}
