import { IsInt, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateArticleDto {
  @IsString()
  @IsNotEmpty()
  titleAr: string;

  @IsString()
  @IsOptional()
  titleEn?: string;

  @IsString()
  @IsNotEmpty()
  summaryAr: string;

  @IsString()
  @IsOptional()
  summaryEn?: string;

  @IsString()
  @IsNotEmpty()
  contentMarkdownAr: string;

  @IsString()
  @IsOptional()
  contentMarkdownEn?: string;

  @IsString()
  @IsOptional()
  categoryId?: string;

  @IsInt()
  @IsOptional()
  readTimeMinutes?: number;

  @IsString()
  @IsOptional()
  mediaUrl?: string;
}
