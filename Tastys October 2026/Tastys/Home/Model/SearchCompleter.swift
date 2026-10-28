//
//  SearchCompleter.swift
//  Tastys
//
//  Created by Nnagoziem Collins Okegbe on 17/06/2026.
//

import SwiftUI
import MapKit

@MainActor
final class AddressSearchViewModel: NSObject, ObservableObject {

    @Published var query = ""
    @Published var suggestions: [MKLocalSearchCompletion] = []

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()

        completer.resultTypes = .address
        completer.delegate = self
    }

    func updateQuery(_ text: String) {
        query = text
        completer.queryFragment = text
    }
}

extension AddressSearchViewModel: MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        suggestions = []
    }
}
