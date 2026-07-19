import prisma from "../config/prisma";

// Small re-export shim so older import paths like `../models/prisma` work
export default prisma;
export { prisma };
