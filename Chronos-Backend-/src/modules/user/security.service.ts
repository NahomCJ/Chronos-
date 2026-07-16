const mock2FADB: Record<string, string> = {};
const mockNotifications: any[] = [];

export const enable2FA = (userId: string, method: string) => {
    const code = '123456'; // fixed for mock
    mock2FADB[userId] = code;
    return { message: `2FA code sent via ${method}`, code };
};

export const verify2FA = (userId: string, code: string) => {
    const valid = mock2FADB[userId] === code;
    return { verified: valid };
};

export const sendNotification = (userId: string, message: string) => {
    const note = { id: Date.now(), userId, message, sentAt: new Date() };
    mockNotifications.push(note);
    return note;
};

export const getNotificationHistory = (userId: string) => {
    return mockNotifications.filter(n => n.userId === userId);
};
