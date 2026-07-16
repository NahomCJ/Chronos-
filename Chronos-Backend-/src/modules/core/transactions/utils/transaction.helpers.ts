export const generateTransactionId = () => {
    return 'tx_' + Math.random().toString(36).substr(2, 9);
};
