export interface LoginInput {
  email: string;
  password: string;
}

export interface RegisterInput {
  email: string;
  password: string;
  firstName: string;
  middleName: string;
  lastName: string;
  role?: "USER" | "ADMIN";
}

export interface JwtPayload {
  userId: string;
  email: string;
  role: string;  // <-- ADD THIS
}
