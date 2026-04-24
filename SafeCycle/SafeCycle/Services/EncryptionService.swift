import CryptoKit
import Foundation

final class EncryptionService {

    static func deriveKey(from password: String, salt: Data) -> SymmetricKey {
        let inputKeyMaterial = SymmetricKey(data: password.data(using: .utf8) ?? Data())
        return HKDF<SHA256>.deriveKey(
            inputKeyMaterial: inputKeyMaterial,
            salt: salt,
            info: Data("SafeCycle.AES256".utf8),
            outputByteCount: 32
        )
    }

    static func encrypt(_ plaintext: Data, with key: SymmetricKey) throws -> Data {
        let nonce = AES.GCM.Nonce()
        let sealedBox = try AES.GCM.seal(plaintext, using: key, nonce: nonce)
        return sealedBox.combined!
    }

    static func decrypt(_ ciphertext: Data, with key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: ciphertext)
        return try AES.GCM.open(sealedBox, using: key)
    }

    static func encryptJSON<T: Encodable>(_ value: T, with key: SymmetricKey) throws -> Data {
        let jsonData = try JSONEncoder().encode(value)
        return try encrypt(jsonData, with: key)
    }

    static func decryptJSON<T: Decodable>(_ type: T.Type, from data: Data, with key: SymmetricKey) throws -> T {
        let decryptedData = try decrypt(data, with: key)
        return try JSONDecoder().decode(type, from: decryptedData)
    }
}
