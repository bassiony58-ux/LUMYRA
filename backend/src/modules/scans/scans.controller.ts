import {
  Controller,
  Post,
  Get,
  Patch,
  Delete,
  Param,
  Body,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ScansService } from './scans.service';
import { RequestUploadGrantDto, RegisterScanDto, CreateDoctorReviewDto, AnalyzeScanDto } from './dto/scan.dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { DoctorApprovedGuard } from '../../common/guards/doctor-approved.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';

@Controller('scans')
@UseGuards(FirebaseAuthGuard, DoctorApprovedGuard)
export class ScansController {
  constructor(private readonly scansService: ScansService) {}

  @Post('upload-grant')
  async requestUploadGrant(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: RequestUploadGrantDto,
  ) {
    return this.scansService.requestUploadGrant(user, dto);
  }

  @Post('register')
  async registerScan(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: RegisterScanDto,
  ) {
    return this.scansService.registerScan(user, dto);
  }

  @Post('analyze')
  @UseInterceptors(
    FileInterceptor('file', {
      limits: { fileSize: 15 * 1024 * 1024 }, // 15MB limit
      fileFilter: (req, file, cb) => {
        const mime = (file.mimetype || '').toLowerCase();
        const originalName = (file.originalname || '').toLowerCase();
        const hasValidExt =
          originalName.endsWith('.jpg') ||
          originalName.endsWith('.jpeg') ||
          originalName.endsWith('.png');
        const hasValidMime =
          mime === 'image/jpeg' ||
          mime === 'image/png' ||
          mime === 'image/jpg' ||
          (mime === 'application/octet-stream' && hasValidExt);

        if (!hasValidExt || !hasValidMime) {
          return cb(
            new BadRequestException(
              'صيغة الملف غير مدعومة. يقبل النظام صور الأشعة بصيغة JPG أو PNG فقط.',
            ),
            false,
          );
        }
        cb(null, true);
      },
    }),
  )
  async analyzeScan(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: AnalyzeScanDto,
    @UploadedFile() file?: any,
  ) {
    return this.scansService.analyzeScan(user, dto, file);
  }

  @Get(':id/access-url')
  async getSecureUrl(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.scansService.getSecureAccessUrl(id, user);
  }

  @Post(':id/doctor-review')
  async submitReview(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateDoctorReviewDto,
  ) {
    return this.scansService.submitDoctorReview(id, user, dto);
  }

  @Patch(':id')
  async renameScan(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser,
    @Body('filename') filename: string,
  ) {
    return this.scansService.renameScan(id, filename, user);
  }

  @Delete(':id')
  async deleteScan(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.scansService.deleteScan(id, user);
  }
}
