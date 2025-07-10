import Foundation
import UIKit
import CoreImage

class QRCodeGenerator: ObservableObject {
    static let shared = QRCodeGenerator()
    
    private init() {}
    
    // MARK: - QR Code Generation
    
    func generateQRCode(for rsvp: RSVP, event: Event) -> String {
        let qrData = QRCodeData(
            rsvpId: rsvp.id,
            eventId: event.id,
            guestId: rsvp.guestId,
            guestName: rsvp.guestName,
            eventName: event.name,
            eventDate: event.date,
            timestamp: Date(),
            signature: generateSignature(rsvpId: rsvp.id, eventId: event.id)
        )
        
        return encodeQRData(qrData)
    }
    
    func generateQRCodeImage(from qrString: String, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        let data = qrString.data(using: String.Encoding.ascii)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        
        guard let outputImage = filter.outputImage else {
            return nil
        }
        
        let scaleX = size.width / outputImage.extent.size.width
        let scaleY = size.height / outputImage.extent.size.height
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - QR Code Validation
    
    func validateQRCode(_ qrString: String, for eventId: String) -> QRValidationResult {
        guard let qrData = decodeQRData(qrString) else {
            return QRValidationResult(
                isValid: false,
                rsvpId: nil,
                guestName: nil,
                errorMessage: "Invalid QR code format"
            )
        }
        
        // Validate event ID
        guard qrData.eventId == eventId else {
            return QRValidationResult(
                isValid: false,
                rsvpId: qrData.rsvpId,
                guestName: qrData.guestName,
                errorMessage: "QR code is for a different event"
            )
        }
        
        // Validate signature
        let expectedSignature = generateSignature(rsvpId: qrData.rsvpId, eventId: qrData.eventId)
        guard qrData.signature == expectedSignature else {
            return QRValidationResult(
                isValid: false,
                rsvpId: qrData.rsvpId,
                guestName: qrData.guestName,
                errorMessage: "Invalid QR code signature"
            )
        }
        
        // Check expiration (optional - QR codes could expire after the event)
        let dayAfterEvent = Calendar.current.date(byAdding: .day, value: 1, to: qrData.eventDate) ?? qrData.eventDate
        guard Date() <= dayAfterEvent else {
            return QRValidationResult(
                isValid: false,
                rsvpId: qrData.rsvpId,
                guestName: qrData.guestName,
                errorMessage: "QR code has expired"
            )
        }
        
        return QRValidationResult(
            isValid: true,
            rsvpId: qrData.rsvpId,
            guestName: qrData.guestName,
            errorMessage: nil
        )
    }
    
    // MARK: - Batch QR Code Generation
    
    func generateQRCodesForEvent(_ event: Event, rsvps: [RSVP]) -> [String: String] {
        var qrCodes: [String: String] = [:]
        
        for rsvp in rsvps where rsvp.status == .yes {
            let qrCode = generateQRCode(for: rsvp, event: event)
            qrCodes[rsvp.id] = qrCode
        }
        
        return qrCodes
    }
    
    func generateQRCodeImages(for qrCodes: [String]) -> [String: UIImage] {
        var images: [String: UIImage] = [:]
        
        for qrCode in qrCodes {
            if let image = generateQRCodeImage(from: qrCode) {
                images[qrCode] = image
            }
        }
        
        return images
    }
    
    // MARK: - Private Methods
    
    private func encodeQRData(_ qrData: QRCodeData) -> String {
        do {
            let jsonData = try JSONEncoder().encode(qrData)
            return jsonData.base64EncodedString()
        } catch {
            print("Error encoding QR data: \(error)")
            return ""
        }
    }
    
    private func decodeQRData(_ qrString: String) -> QRCodeData? {
        guard let data = Data(base64Encoded: qrString) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(QRCodeData.self, from: data)
        } catch {
            print("Error decoding QR data: \(error)")
            return nil
        }
    }
    
    private func generateSignature(rsvpId: String, eventId: String) -> String {
        let combined = "\(rsvpId):\(eventId):INVITII_SECRET_KEY"
        return combined.sha256
    }
}

// MARK: - QR Code Data Models

struct QRCodeData: Codable {
    let rsvpId: String
    let eventId: String
    let guestId: String
    let guestName: String
    let eventName: String
    let eventDate: Date
    let timestamp: Date
    let signature: String
    
    // Version for future compatibility
    let version: Int = 1
}

struct QRValidationResult {
    let isValid: Bool
    let rsvpId: String?
    let guestName: String?
    let errorMessage: String?
}

// MARK: - QR Code Styling

struct QRCodeStyle {
    let backgroundColor: UIColor
    let foregroundColor: UIColor
    let logo: UIImage?
    let cornerRadius: CGFloat
    
    static let `default` = QRCodeStyle(
        backgroundColor: .white,
        foregroundColor: .black,
        logo: nil,
        cornerRadius: 8.0
    )
    
    static let invitii = QRCodeStyle(
        backgroundColor: .white,
        foregroundColor: UIColor.systemPurple,
        logo: UIImage(systemName: "envelope.fill"),
        cornerRadius: 12.0
    )
}

extension QRCodeGenerator {
    func generateStyledQRCodeImage(
        from qrString: String,
        style: QRCodeStyle = .invitii,
        size: CGSize = CGSize(width: 250, height: 250)
    ) -> UIImage? {
        guard let qrImage = generateQRCodeImage(from: qrString, size: size) else {
            return nil
        }
        
        // Create styled version
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            
            // Background
            style.backgroundColor.setFill()
            context.fill(rect)
            
            // QR Code with custom color
            if let coloredQRImage = qrImage.withTintColor(style.foregroundColor) {
                coloredQRImage.draw(in: rect)
            } else {
                qrImage.draw(in: rect)
            }
            
            // Logo in center (if provided)
            if let logo = style.logo {
                let logoSize = CGSize(width: size.width * 0.2, height: size.height * 0.2)
                let logoRect = CGRect(
                    x: (size.width - logoSize.width) / 2,
                    y: (size.height - logoSize.height) / 2,
                    width: logoSize.width,
                    height: logoSize.height
                )
                
                // White background for logo
                style.backgroundColor.setFill()
                context.fillEllipse(in: logoRect.insetBy(dx: -5, dy: -5))
                
                logo.draw(in: logoRect)
            }
        }
    }
}

// MARK: - Utility Extensions

extension String {
    var sha256: String {
        guard let data = self.data(using: .utf8) else { return "" }
        
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// Import CommonCrypto for SHA256
import CommonCrypto

extension UIImage {
    func withTintColor(_ color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        color.set()
        withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}