//
//  TextField+Label.swift
//  PocketFlow
//
//  Created by Alexander Callebaut on 30/12/2024.
//

import SwiftUI

struct TextFieldValidationView<Content: View>: View  {
    
    let label: String
    @Binding var validationErrors: [ValidationError]
    let validationKey: String
    let content: () -> Content
    
    init(label: String, validationErrors: Binding<[ValidationError]>, validationKey: String, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self._validationErrors = validationErrors
        self.validationKey = validationKey
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
            content()
                .padding()
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(10)
            if validationErrors.contains(where: { $0.key == validationKey }) {
                ForEach(validationErrors.filter { $0.key == validationKey }, id: \.self) { validationError in
                   Text(validationError.message)
                       .foregroundStyle(.red)
               }
           }
        }
    }
}
