enum ContactMode {
    case Show
    case Add
    case Edit
    
    func getTitleMode() -> String {
        switch self {
        case .Add:
            return "Add contact"
        case .Edit:
            return "Edit contact"
        case .Show:
            return "Contact information"
        }
    }
    
    func getItemButton() -> String {
        if (self == .Show){
            return "Edit"
        } else {
            return "Save"
        }
    }
}