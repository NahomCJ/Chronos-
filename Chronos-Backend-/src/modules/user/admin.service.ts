const mockUsers = [{ id: '1', name: 'Alice' }, { id: '2', name: 'Bob' }];
const mockAuditLogs: any[] = [];

export const getUsers = () => mockUsers;

export const lockAccount = (userId: string) => ({
    message: `Account ${userId} locked`,
});

export const getAuditLogs = () => mockAuditLogs;

export const impersonate = (userId: string) => ({
    message: `Impersonating ${userId}`,
    token: 'mock-admin-token',
});
