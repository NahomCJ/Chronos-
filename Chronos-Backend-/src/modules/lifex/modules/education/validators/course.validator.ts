import { body } from "express-validator";


export const createCourseValidators = [
body("title").isString().notEmpty(),
body("provider").isString().notEmpty(),
body("price").optional().isNumeric(),
];