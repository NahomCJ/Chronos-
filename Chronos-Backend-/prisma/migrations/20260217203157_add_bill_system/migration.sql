-- AlterTable
ALTER TABLE "Card" ADD COLUMN     "panToken" TEXT,
ADD COLUMN     "walletId" TEXT;

-- AddForeignKey
ALTER TABLE "Card" ADD CONSTRAINT "Card_walletId_fkey" FOREIGN KEY ("walletId") REFERENCES "Wallet"("id") ON DELETE SET NULL ON UPDATE CASCADE;
