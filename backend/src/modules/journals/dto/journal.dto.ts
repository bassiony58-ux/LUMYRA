import { IsBoolean, IsNotEmpty, IsOptional, IsString, IsArray } from 'class-validator';

export class CreateJournalEntryDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsNotEmpty()
  content: string;

  @IsString()
  @IsOptional()
  mood?: string;

  @IsArray()
  @IsOptional()
  symptoms?: string[];

  @IsBoolean()
  @IsOptional()
  isSharedWithDoctor?: boolean = false;
}

export class UpdateJournalEntryDto {
  @IsString()
  @IsOptional()
  title?: string;

  @IsString()
  @IsOptional()
  content?: string;

  @IsString()
  @IsOptional()
  mood?: string;

  @IsArray()
  @IsOptional()
  symptoms?: string[];

  @IsBoolean()
  @IsOptional()
  isSharedWithDoctor?: boolean;
}
