import CBORCoding
import Foundation

struct MDocModel: Decodable {
    let version: String
    
    let documents: [Document]
    
    //    init?(cbor: CBOR) {
    //        if case .utf8String(let version) = cbor["version"] {
    //            self.version = version
    //        } else {
    //            self.version = "0"
    //        }
    //    }
}

struct Document: Decodable {
    let docType: String
    let issuerSigned: IssuerSigned
    //    let deviceSigned: DeviceSigned
}

struct IssuerSigned: Decodable {
    let nameSpaces: NameSpaces
    //    let issuerAuth: [IssuerAuth]
}

struct NameSpaces: Decodable {
    let object: [DocumentField]
    
    enum CodingKeys: String, CodingKey {
        case object = "org.iso.18013.5.1"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

//        dump(container)

        let fields = try container.decode([Data].self, forKey: NameSpaces.CodingKeys.object)

        let cborDecoder = CBORDecoder()
        try fields.forEach {
            let decoded = try cborDecoder.decode(DocumentField.self, from: $0)
            print(decoded)
        }

        let zero = try cborDecoder.decode(DocumentField.self, from: fields[0])
        let two = try cborDecoder.decode(DocumentField.self, from: fields[2])
        let three = try cborDecoder.decode(DocumentField.self, from: fields[3])
        let four = try cborDecoder.decode(DocumentField.self, from: fields[4])
        let five = try cborDecoder.decode(DocumentField.self, from: fields[5])
//
//        let docs = [zero,
////                    two,
//                    three,
//                    four
////                    five
//        ]
//        dump(docs)

//        object = fields
        object = []
    }
}

struct DocumentField: Decodable {
    let digestID: Int
    let random: Data
    let elementIdentifier: String
    let elementValue: ElementValue
    
    enum CodingKeys: CodingKey {
        case digestID
        case random
        case elementIdentifier
        case elementValue
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.digestID = 0
        self.random = try container.decode(Data.self, forKey: .random)
        self.elementIdentifier = try container.decode(String.self, forKey: .elementIdentifier)
        self.elementValue = try container.decode(ElementValue.self, forKey: .elementValue)
    }
}

enum ElementValue: Decodable {
    case string(String)
    case int(Int)
    case date(Int, Date)
    case float(Float)
    case data(Data)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let dateValue = try? container.decode([Int: Date].self) {
            self = .date(dateValue.first!.key, dateValue.first!.value)
        } else if let floatValue = try? container.decode(Float.self) {
            self = .float(floatValue)
        } else if let dataValue = try? container.decode(Data.self) {
            self = .data(dataValue)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath,
                                      debugDescription: "Unable to decode firstName")
            )
        }
    }
}

struct IssuerAuth: Decodable {
}

struct DeviceSigned: Decodable {
}
