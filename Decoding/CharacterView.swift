//
//  CharacterView.swift
//  Decoding
//
//  Created by Dillon McElhinney on 8/22/22.
//

import SwiftUI

struct Character: Codable {
    let id: Int
    let name: String
    let image: URL
    let occupation: String?
    let voicedBy: String?
    let wikiUrl: URL
    let relatives: [Relative]?
}

extension Character {
    struct Relative: Codable {
        let name: String
        let wikiUrl: URL
        let url: URL
    }
}

class BobsBurgersApi {
    static let shared = BobsBurgersApi()
    private static let baseUrl = URL(string: "https://bobsburgers-api.herokuapp.com")!

    private init() {}

    func fetchCharacter(id: Int) async -> Character? {
        let url = Self.baseUrl
            .appendingPathComponent("characters")
            .appendingPathComponent("\(id)")
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let character = try JSONDecoder().decode(Character.self, from: data)
            return character
        } catch {
            print(error)
            return nil
        }
    }
}

@MainActor
class CharacterViewModel: ObservableObject {

    @Published var character: Character?

    var title: String { character?.name ?? "" }
    var subtitle: String { character?.occupation ?? "" }
    var subtitle2: String {
        let relatives = character?.relatives?.map(\.name).joined(separator: ", ")
        return relatives.map { "Relatives: \($0)" } ?? ""
    }
    var detail: String { (character?.voicedBy).map { "Voiced by: \($0)" } ?? "" }
    var learnMore: URL { character?.wikiUrl ?? URL(string: "https://bobs-burgers.fandom.com")! }

    private var api: BobsBurgersApi { .shared }

    func changeCharacter() {
        Task {
            character = await api.fetchCharacter(id: .random(in: 1...501))
        }
    }
}

struct CharacterView: View {
    @StateObject var viewModel = CharacterViewModel()

    var body: some View {
        VStack {
            AsyncImage(url: viewModel.character?.image) { phase in
                phase.image?.resizable()
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 300, height: 300, alignment: .center)
            Spacer()
            Text(viewModel.title)
                .font(.title)
            Text(viewModel.subtitle)
            if !viewModel.subtitle2.isEmpty {
                Text(viewModel.subtitle2)
            }
            Text(viewModel.detail)
                .font(.caption)
            if !viewModel.title.isEmpty {
                Link("Learn More", destination: viewModel.learnMore)
                    .font(.caption)
            }
            Button("New Character") {
                viewModel.changeCharacter()
            }.padding()
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

struct CharacterView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterView()
    }
}
