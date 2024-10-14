@testable import CBORCoding
import Foundation
import Half
import XCTest

class MDLTests: XCTestCase {
    
    // MARK: Test Methods
    
    func testRefSpec() {
        let filePath = Bundle(for: type(of: self)).path(forResource: "MdlResponseFromSpec", ofType: nil)

        do {
            // With Both SwiftCBOR and CBOREncoding Data must be coverted from a hex string before coverting back into data
            // Directly using data from file and passing to decoder will lead to errors in decoding
            
            // In cases of getting response from backend via URLSession would assume this is the correct order to decoding object
            // ResponseData -> String -> HexData/[UInt8] -> Decoder
            // Note that CBORCoding allows Data type to be used when decoding but SwiftCBOR must use [UInt8] if using 'CBORDecoder'
            // SwiftCBOR's CodableCBORDecoder allows for Data type to be used but must be hexData just like CBORCoding
            
            // Note on hexData: this String extension is copied over from SwiftCBOR Tests, only this extension was copied other extension could prove useful in future
            
//            let data = try Data(contentsOf: URL(filePath: filePath!))
//            guard let dataString = String(data: data, encoding: .utf8) else { return }
//            let decoded = try CBORDecoder().decode(SomeModel.self, from: dataString.hexaData)
//            print(decoded)
            
            if #available(iOS 16.0, *) {
                let hexString = try String(contentsOf: URL(filePath: filePath!), encoding: .utf8)
                let hexData = convertFromHexString(hexString)
                let decode = try CBORDecoder().decode(MDocModel.self, from: hexData)
                print(decode)
    //            return decode
                
            } else {
                // Fallback on earlier versions
            }
            
        } catch {
            print(error)
        }
    }
}


private func convertFromHexString(_ string: String) -> Data {
    var hex = string.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "")
    hex = hex.starts(with: "0x") ? String(hex.dropFirst(2)) : hex

    if (hex.count % 2) == 1 { // odd number of hex characters
        hex.insert(contentsOf: "0", at: hex.startIndex)
    }

    var data = Data(capacity: hex.count / 2)
    for i in stride(from: 0, to: hex.count, by: 2) {
        let map = { (character: Character) -> UInt8 in
            switch character {
            case "0": return 0x00
            case "1": return 0x01
            case "2": return 0x02
            case "3": return 0x03
            case "4": return 0x04
            case "5": return 0x05
            case "6": return 0x06
            case "7": return 0x07
            case "8": return 0x08
            case "9": return 0x09
            case "A": return 0x0A
            case "B": return 0x0B
            case "C": return 0x0C
            case "D": return 0x0D
            case "E": return 0x0E
            case "F": return 0x0F
            default:  preconditionFailure("Invalid hex character: \(character)")
            }
        }

        data.append(map(hex[hex.index(hex.startIndex, offsetBy: i)]) << 4 |
            map(hex[hex.index(hex.startIndex, offsetBy: i + 1)]))
    }

    return data
}
