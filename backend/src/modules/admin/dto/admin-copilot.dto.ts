import { IsNotEmpty, IsString } from 'class-validator';

export class AdminCopilotDto {
  @IsString()
  @IsNotEmpty()
  query: string;
}
