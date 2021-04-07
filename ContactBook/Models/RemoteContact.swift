import Foundation

protocol ContactsRemote {
    
    func getContacts() throws -> [Contact]
}

enum URLError: Error {
    case incorrectUrl
    case errorGettingData
}

class RemoteContactsDataTask: ContactsRemote {
    
    private var contacts = [Contact]()
    private let urlAddress = "https://gist.githubusercontent.com/artgoncharov/61c471db550238f469ad746a0c3102a7/raw/590dcd89a6aa10662c9667138c99e4b0a8f43c67/contacts_data2.json"
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
                    Contact().builder
                        .set(name: $0.name)
                        .set(surname: $0.surname)
                        .set(phone: $0.phoneNumber)
                        .set(email: $0.email)
                        .set(hash: $0.hash)
                        .set(photoURL: $0.photoUrl)
                        .build()
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
