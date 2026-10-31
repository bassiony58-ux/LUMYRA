import { Controller, Get, Post, Put, Delete, Param, Query, Body, UseGuards } from '@nestjs/common';
import { EducationalService } from './educational.service';
import { CreateArticleDto } from './dto/create-article.dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuthenticatedUser, UserRole } from '../../common/interfaces/authenticated-user.interface';

@Controller('educational')
export class EducationalController {
  constructor(private readonly educationalService: EducationalService) {}

  @Get('categories')
  async listCategories() {
    return this.educationalService.listCategories();
  }

  @Get('articles')
  async listArticles(
    @Query('categoryId') categoryId?: string,
  ) {
    return this.educationalService.listArticles(categoryId);
  }

  @Post('articles')
  @UseGuards(FirebaseAuthGuard, RolesGuard)
  @Roles(UserRole.DOCTOR, UserRole.ADMIN)
  async createArticle(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateArticleDto,
  ) {
    return this.educationalService.createArticle(user, dto);
  }

  @Put('articles/:id')
  @UseGuards(FirebaseAuthGuard, RolesGuard)
  @Roles(UserRole.DOCTOR, UserRole.ADMIN)
  async updateArticle(
    @Param('id') id: string,
    @Body() dto: Partial<CreateArticleDto>,
  ) {
    return this.educationalService.updateArticle(id, dto);
  }

  @Delete('articles/:id')
  @UseGuards(FirebaseAuthGuard, RolesGuard)
  @Roles(UserRole.DOCTOR, UserRole.ADMIN)
  async deleteArticle(@Param('id') id: string) {
    return this.educationalService.deleteArticle(id);
  }

  @Get('articles/:idOrSlug')
  async getArticle(@Param('idOrSlug') idOrSlug: string) {
    return this.educationalService.getArticleByIdOrSlug(idOrSlug);
  }
}

