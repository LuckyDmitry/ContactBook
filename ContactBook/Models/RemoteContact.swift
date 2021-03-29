import Foundation

protocol RemoteContacts {
    
    func getContacts() throws -> [Contact]
}

enum URLError: Error {
    case incorrectUrl
    case errorGettingData
}

class RemoteContactsDataTask: RemoteContacts {
    
    private var contacts = [Contact]()
    private let urlAddress = "https://gist.githubusercontent.com/artgoncharov/d257658423edd46a9ead5f721b837b8c/raw/c38ace33a7c871e4ad3b347fc4cd970bb45561a3/contacts_data.json"
    var url: URL
    
    init?() {
        guard let unwrappedUrl = URL(string: urlAddress) else {
            return nil
        }
        self.url = unwrappedUrl
    }
    
    func getContacts() throws -> [Contact] {
        
        let semaphore = DispatchSemaphore(value: 0)
        let urlRequest = URLRequest(url: url)
        var contacts = [Contact]()
        
        let request = URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
            
            defer {
                semaphore.signal()
            }
            guard let data = data else {
                return
            }
            do {
                let result = try JSONDecoder().decode([Contact].self, from: data)
                contacts = result.map{
                    Contact(contactName: $0.name, contactSurname: $0.surname, number: $0.phoneNumber, email: $0.email)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        request.resume()
        let result = semaphore.wait(timeout: .now() + .seconds(5))
        if result == .success {
            return contacts
        }
        throw URLError.errorGettingData
    }
}
