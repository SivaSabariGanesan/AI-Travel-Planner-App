import crypto from "crypto";
import { AppError } from "./appError";

const ALGORITHM = "aes-256-gcm";

const getKey = (): Buffer => {
  const secret = process.env.GEMINI_KEY_ENCRYPTION_SECRET;

  if (!secret || secret.length < 24) {
    throw new AppError(
      "GEMINI_KEY_ENCRYPTION_SECRET must be set and at least 24 characters",
      500,
    );
  }

  return crypto.createHash("sha256").update(secret).digest();
};

export const encryptText = (plainText: string): string => {
  const iv = crypto.randomBytes(12);
  const key = getKey();
  const cipher = crypto.createCipheriv(ALGORITHM, key, iv);

  const encrypted = Buffer.concat([
    cipher.update(plainText, "utf8"),
    cipher.final(),
  ]);
  const authTag = cipher.getAuthTag();

  return `${iv.toString("base64")}:${authTag.toString("base64")}:${encrypted.toString("base64")}`;
};

export const decryptText = (cipherText: string): string => {
  const [ivEncoded, authTagEncoded, encryptedEncoded] = cipherText.split(":");

  if (!ivEncoded || !authTagEncoded || !encryptedEncoded) {
    throw new AppError("Invalid encrypted data", 500);
  }

  const key = getKey();
  const iv = Buffer.from(ivEncoded, "base64");
  const authTag = Buffer.from(authTagEncoded, "base64");
  const encrypted = Buffer.from(encryptedEncoded, "base64");

  const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
  decipher.setAuthTag(authTag);

  const decrypted = Buffer.concat([
    decipher.update(encrypted),
    decipher.final(),
  ]);

  return decrypted.toString("utf8");
};
