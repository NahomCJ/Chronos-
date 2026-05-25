// Adapter to re-export auth middleware used across the project.
// Some modules import from '../../middlewares/auth.middleware' while the implementation
// lives in 'src/modules/auth/middlewares/auth.middleware.ts'. This file keeps a
// stable import path for those modules.
import {
  authMiddleware as _authMiddleware,
} from "../modules/auth/middlewares/auth.middleware";

// Provide common named exports used across the codebase.
export const auth = _authMiddleware;
export const authMiddleware = _authMiddleware;

// Backwards-compatible aliases used in some files
export const requireAuth = _authMiddleware;
export const authenticate = _authMiddleware;

export default _authMiddleware;
