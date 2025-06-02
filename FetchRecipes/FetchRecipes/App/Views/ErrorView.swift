//
//  ErrorView.swift
//  FetchRecipes
//
//  Created by Srilu Rao on 5/31/25.
//

import SwiftUI

struct ErrorView: View {
    let error: NetworkError
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text(error.errorDescription ?? "Unknown error occurred")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Button("Retry", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

//#Preview {
//    ErrorView()
//}
