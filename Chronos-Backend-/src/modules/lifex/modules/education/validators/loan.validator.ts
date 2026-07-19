import { body } from "express-validator";


export const linkLoanValidators = [
body("lender").isString().notEmpty(),
body("principal").isNumeric(),
body("outstanding").isNumeric(),
];