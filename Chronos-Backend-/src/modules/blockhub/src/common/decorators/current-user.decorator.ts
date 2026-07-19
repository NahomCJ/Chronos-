import { createParamDecorator } from '@nestjs/common';

export interface JwtPayload {
  sub: string;    // user ID
  email: string;
  iat: number;
  exp: number;
}

export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: any): JwtPayload => {
    const request = ctx.switchToHttp().getRequest();
    return request.user;
  },
);
