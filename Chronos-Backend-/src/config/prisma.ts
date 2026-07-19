import { PrismaClient } from "@prisma/client";
import dotenv from "dotenv";

const envFile = process.env.NODE_ENV === "test" ? ".env.test" : ".env";
dotenv.config({ path: envFile });

const prisma = new PrismaClient();

export default prisma;
