enum ContactMode {
    case show
    case add
    case edit
    
    func getTitleMode() -> String {
        switch self {
        case .add:
            return "Add contact"
        case .edit:
            return "Edit contact"
        case .show:
            return "Contact information"
        }
    }
    
    func getItemButton() -> String {
        if (self == .show){
            return "Edit"
        } else {
            return "Save"
        }
    }
}
