import Foundation
import CryptoKit

// MARK: - Слой безопасности для Inferno

class InfernoSecurityLayer {
    static let shared = InfernoSecurityLayer()
    
    private let infernoKeychain = "com.egginfernogame.keychain"
    private let infernoSalt = "EggInferno2Salt"
    
    private init() {}
    
    func generateInfernoSessionToken() -> String {
        let timestamp = Date().timeIntervalSince1970
        let randomBytes = Data((0..<16).map { _ in UInt8.random(in: 0...255) })
        let combined = "\(timestamp)_\(randomBytes.base64EncodedString())"
        return hashInfernoString(combined)
    }
    
    private func hashInfernoString(_ input: String) -> String {
        let data = Data(input.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func validateInfernoEndpoint(_ url: String) -> Bool {
        guard let urlObj = URL(string: url) else { return false }
        
        // Проверяем домен
        let allowedDomains = ["egginferno2.com", "www.egginferno2.com"]
        guard let host = urlObj.host,
              allowedDomains.contains(host) else { return false }
        
        // Проверяем протокол
        return urlObj.scheme == "https"
    }
    
    func encryptInfernoData(_ data: String) -> String {
        let key = SymmetricKey(data: Data(infernoSalt.utf8))
        guard let dataToEncrypt = data.data(using: .utf8) else { return data }
        
        do {
            let sealedBox = try AES.GCM.seal(dataToEncrypt, using: key)
            return sealedBox.combined?.base64EncodedString() ?? data
        } catch {
            return data
        }
    }
    
    func decryptInfernoData(_ encryptedData: String) -> String {
        let key = SymmetricKey(data: Data(infernoSalt.utf8))
        guard let dataToDecrypt = Data(base64Encoded: encryptedData) else { return encryptedData }
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: dataToDecrypt)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return String(data: decryptedData, encoding: .utf8) ?? encryptedData
        } catch {
            return encryptedData
        }
    }
}

// MARK: - Утилиты для обфускации

extension InfernoSecurityLayer {
    func obfuscateInfernoString(_ input: String) -> String {
        let chars = Array(input)
        let shuffled = chars.enumerated().map { index, char in
            let shift = (index % 3) + 1
            let ascii = Int(char.asciiValue ?? 0)
            let newAscii = (ascii + shift) % 256
            return Character(UnicodeScalar(newAscii) ?? UnicodeScalar(char.asciiValue ?? 0))
        }
        return String(shuffled)
    }
    
    func deobfuscateInfernoString(_ input: String) -> String {
        let chars = Array(input)
        let original = chars.enumerated().map { index, char in
            let shift = (index % 3) + 1
            let ascii = Int(char.asciiValue ?? 0)
            let newAscii = (ascii - shift + 256) % 256
            return Character(UnicodeScalar(newAscii) ?? UnicodeScalar(char.asciiValue ?? 0))
        }
        return String(original)
    }
}
