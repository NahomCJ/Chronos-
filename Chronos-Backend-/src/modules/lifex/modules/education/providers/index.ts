export { CourseraProvider } from "./coursera.provider";
export { UdemyProvider } from "./udemy.provider";
export { EdxProvider } from "./edx.provider";
export { LocalProvider } from "./local.provider";


import { CourseProvider } from "./base.provider";
import { CourseraProvider as C } from "./coursera.provider";
import { UdemyProvider as U } from "./udemy.provider";
import { EdxProvider as E } from "./edx.provider";
import { LocalProvider as L } from "./local.provider";


export const Providers: CourseProvider[] = [C, U, E, L];