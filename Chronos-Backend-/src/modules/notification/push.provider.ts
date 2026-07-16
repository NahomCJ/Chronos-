let _admin: any = null;

async function getAdmin() {
  if (_admin) return _admin;
  const serviceAccount = process.env.FCM_SERVICE_ACCOUNT;
  if (!serviceAccount) return null;
  const admin = (await import("firebase-admin")).default;
  if (!admin.apps.length) {
    admin.initializeApp({ credential: admin.credential.cert(JSON.parse(serviceAccount)) });
  }
  _admin = admin;
  return _admin;
}

export class PushProvider {
  static async sendPush(to: string, title: string, body: string, data?: any) {
    try {
      const admin = await getAdmin();
      if (!admin) return; // FCM not configured, skip silently
      const response = await admin.messaging().send({ token: to, notification: { title, body }, data });
      console.log("Push sent:", response);
      return response;
    } catch (error) {
      console.error("Push failed:", error);
    }
  }
}
