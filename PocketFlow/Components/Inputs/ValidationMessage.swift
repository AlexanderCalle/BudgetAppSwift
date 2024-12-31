//
//  ValidationMessage.swift
//  PocketFlow
//
//  Created by Alexander Callebaut on 31/12/2024.
//

import Foundation
import SwiftUI

struct ValidationMessage: View {
    @Binding var validationErrors: [ValidationError]
    let validationKey: String
    
    var body : some View {
        if validationErrors.contains(where: { $0.key == validationKey }) {
            ForEach(validationErrors.filter { $0.key == validationKey }, id: \.self) { validationError in
               Text(validationError.message)
                   .foregroundStyle(.danger)
           }
       }
    }
}
