// Temporary module shims to quiet missing type declarations while we triage
// and add real types. These are intentionally broad and should be replaced
// with proper @types packages or typed imports later.

declare module 'mongoose';
declare module '@nestjs/common';
declare module '@nestjs/mongoose';
declare module 'bullmq';
declare module 'firebase-admin';
declare module 'moralis';
declare module 'uuid';
declare module 'redis';
declare module 'bull';
declare module 'date-fns';
declare module '@sentry/node';

// allow importing JSON files in some modules if needed
declare module '*.json' {
  const value: any;
  export default value;
}
