enum ContactMode: String {
    case show = "Contact information"
    case add = "Add contact"
    case edit = "Edit contact" 

    func getItemButton() -> String {
        if (self == .show){
            return "Edit"
        } else {
            return "Save"
        }
    }
}
