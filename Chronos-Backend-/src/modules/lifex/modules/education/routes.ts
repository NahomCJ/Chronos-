import { Router } from "express";
import * as coursesCtrl from "./controllers/courses.controller";
import * as scholarshipsCtrl from "./controllers/scholarships.controller";
import * as tutorsCtrl from "./controllers/tutors.controller";
import * as loansCtrl from "./controllers/loans.controller";
import { requireAuth, requireAdmin } from "../../../auth/middlewares/auth.middleware";


const router = Router();


// Courses
router.get("/courses", coursesCtrl.list);
router.get("/courses/:id", coursesCtrl.detail);
router.post("/courses", requireAuth, requireAdmin, coursesCtrl.create);
router.post("/courses/sync", requireAuth, requireAdmin, coursesCtrl.sync);
router.post("/courses/:id/enroll", requireAuth, coursesCtrl.enroll);
router.get("/enrollments", requireAuth, coursesCtrl.listEnrollments);
router.patch("/enrollments/:id/progress", requireAuth, coursesCtrl.updateProgress);


// Scholarships
// router.get("/scholarships", scholarshipsCtrl.list);
// router.get("/scholarships/:id", (scholarshipsCtrl as any).detail);
// router.post("/scholarships/sync", requireAuth, requireAdmin, scholarshipsCtrl.sync);
// router.post("/scholarships/:id/apply", requireAuth, scholarshipsCtrl.apply);


// Tutors
router.get("/tutors", tutorsCtrl.list);
router.get("/tutors/:id", tutorsCtrl.detail);
router.post("/tutors", requireAuth, requireAdmin, tutorsCtrl.create);
router.post("/tutors/:id/schedule", requireAuth, tutorsCtrl.schedule);
router.get("/tutors/sessions", requireAuth, tutorsCtrl.sessions);


// Loans
router.post("/loans/link", requireAuth, loansCtrl.linkManual);
router.get("/loans", requireAuth, loansCtrl.list);
router.post("/loans/:id/repay", requireAuth, loansCtrl.repay);
router.get("/loans/:id/paymentSchedule", requireAuth, loansCtrl.schedule);


export default router;