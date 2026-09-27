import Foundation

struct TriviaService {
    private let urlString = "https://opentdb.com/api.php?amount=10&type=multiple"

    func fetchQuestions() async throws -> [TriviaQuestion] {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)

        return decodedResponse.results
    }
}
