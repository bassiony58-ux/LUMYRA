import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateArticleDto } from './dto/create-article.dto';
import { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';

@Injectable()
export class EducationalService {
  private inMemoryArticles = [
    {
      id: 'art-1',
      titleAr: 'دليلك الشامل للفحص الذاتي الشهري للثدي',
      titleEn: 'Comprehensive Guide to Monthly Breast Self-Examination',
      slug: 'monthly-breast-self-exam-guide',
      summaryAr: 'خطوات عملية واضحة لإجراء الفحص الذاتي وتوقيته الأمثل شهرياً.',
      summaryEn: 'Practical clear steps for monthly self-examination.',
      contentMarkdownAr: '# دليلك للفحص الذاتي\n\nيُعد الفحص الذاتي خطوتك الأولى للاطمئنان الدوري...',
      contentMarkdownEn: '# Breast Self-Exam Guide\n\nSelf-examination is your routine step...',
      categoryId: 'cat-1',
      readTimeMinutes: 5,
      isPublished: true,
      createdAt: new Date().toISOString(),
    },
    {
      id: 'art-2',
      titleAr: 'ماذا تعني أرقام وتصنيفات BI-RADS في تقرير الأشعة؟',
      titleEn: 'Understanding BI-RADS Categories in Breast Imaging',
      slug: 'understanding-birads-categories',
      summaryAr: 'شرح مبسط لمعاني تصنيفات بي-رادس من 1 إلى 5 وكيف يتعامل معها الأطباء.',
      summaryEn: 'A clear guide to BI-RADS scores from 1 to 5.',
      contentMarkdownAr: '# ما هو نظام BI-RADS؟\n\nنظام دولي معتمد لتصنيف نتائج الأشعة...',
      contentMarkdownEn: '# What is BI-RADS?\n\nAn international standard for imaging scores...',
      categoryId: 'cat-2',
      readTimeMinutes: 7,
      isPublished: true,
      createdAt: new Date().toISOString(),
    },
  ];

  constructor(private readonly prisma: PrismaService) {}

  async listCategories() {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      return [
        { id: 'cat-1', nameAr: 'الفحص الذاتي والتوعية', nameEn: 'Self-Examination & Awareness', slug: 'self-exam' },
        { id: 'cat-2', nameAr: 'الأشعة والتشخيص', nameEn: 'Imaging & Diagnostics', slug: 'imaging' },
      ];
    }
    return this.prisma.educationalCategory.findMany({
      orderBy: { nameEn: 'asc' },
    });
  }

  async listArticles(categoryId?: string) {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      let list = [...this.inMemoryArticles];
      if (categoryId) {
        list = list.filter((a) => a.categoryId === categoryId);
      }
      return list;
    }

    return this.prisma.educationalArticle.findMany({
      where: {
        isPublished: true,
        ...(categoryId ? { categoryId } : {}),
      },
      include: {
        category: { select: { id: true, nameAr: true, nameEn: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getArticleByIdOrSlug(idOrSlug: string) {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      const art = this.inMemoryArticles.find((a) => a.id === idOrSlug || a.slug === idOrSlug);
      if (!art) {
        throw new NotFoundException(`المقال غير موجود`);
      }
      return art;
    }

    const article = await this.prisma.educationalArticle.findFirst({
      where: {
        OR: [{ id: idOrSlug }, { slug: idOrSlug }],
        isPublished: true,
      },
      include: {
        category: true,
      },
    });

    if (!article) {
      throw new NotFoundException(`Article ${idOrSlug} not found.`);
    }

    return article;
  }

  async createArticle(user: AuthenticatedUser, dto: CreateArticleDto) {
    const slug = `art-${Date.now()}`;
    const newArticle = {
      id: `art-${Date.now()}`,
      slug,
      categoryId: dto.categoryId || 'cat-1',
      authorId: user.id,
      reviewerDoctorId: user.doctorProfileId || null,
      titleAr: dto.titleAr,
      titleEn: dto.titleEn || dto.titleAr,
      summaryAr: dto.summaryAr,
      summaryEn: dto.summaryEn || dto.summaryAr,
      contentMarkdownAr: dto.contentMarkdownAr,
      contentMarkdownEn: dto.contentMarkdownEn || dto.contentMarkdownAr,
      readTimeMinutes: dto.readTimeMinutes || 5,
      mediaUrl: dto.mediaUrl || null,
      isPublished: true,
      publishedAt: new Date(),
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    if (process.env.SKIP_DB_CONNECT === 'true') {
      this.inMemoryArticles.unshift(newArticle as any);
      return newArticle;
    }

    return this.prisma.educationalArticle.create({
      data: newArticle as any,
    });
  }

  async updateArticle(id: string, dto: Partial<CreateArticleDto>) {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      const art = this.inMemoryArticles.find((a) => a.id === id);
      if (!art) throw new NotFoundException('المقال غير موجود');
      if (dto.titleAr) art.titleAr = dto.titleAr;
      if (dto.summaryAr) art.summaryAr = dto.summaryAr;
      if (dto.contentMarkdownAr) art.contentMarkdownAr = dto.contentMarkdownAr;
      return art;
    }

    return this.prisma.educationalArticle.update({
      where: { id },
      data: dto as any,
    });
  }

  async deleteArticle(id: string) {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      this.inMemoryArticles = this.inMemoryArticles.filter((a) => a.id !== id);
      return { id, deleted: true, message: 'تم حذف المقال بنجاح' };
    }

    await this.prisma.educationalArticle.delete({ where: { id } });
    return { id, deleted: true, message: 'تم حذف المقال بنجاح' };
  }
}

