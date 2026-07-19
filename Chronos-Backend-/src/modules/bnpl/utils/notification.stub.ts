// Local notification shim for BNPL-focused checks. Will forward to the
// real NotificationService when available.
const NotificationService = {
  async sendNotification(_user: any, _payload: any) {
    return;
  },
};

export default NotificationService;
