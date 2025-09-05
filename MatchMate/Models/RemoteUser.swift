import Foundation

struct RemoteUserResponse: Decodable {
    let results: [RemoteUser]
}

struct RemoteUser: Decodable {
    struct Name: Decodable { let title: String?; let first: String; let last: String }
    struct DOB: Decodable { let age: Int }
    struct Location: Decodable { let city: String; let country: String }
    struct Picture: Decodable { let large: String; let medium: String; let thumbnail: String }
    struct Login: Decodable { let uuid: String }

    let name: Name
    let dob: DOB
    let location: Location
    let picture: Picture
    let login: Login
}
