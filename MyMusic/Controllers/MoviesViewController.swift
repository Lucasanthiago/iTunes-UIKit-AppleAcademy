import UIKit
import AVKit
import AVFoundation

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var table: UITableView!  // Conecte no Storyboard
    
    // Nosso array de filmes
    var movies: [Movie] = [
        Movie(name: "Inception",
              releaseYear: "2010",
              directorName: "Christopher Nolan",
              imageName: "cover1",  // Ajuste ao nome real no Assets
              fileName: "movie1"),          // Ajuste ao arquivo real no bundle (.mov ou .mp4)
        
        Movie(name: "Matrix",
              releaseYear: "1999",
              directorName: "The Wachowskis",
              imageName: "cover1",
              fileName: "movie2"),
        
        Movie(name: "Interstellar",
              releaseYear: "2014",
              directorName: "Christopher Nolan",
              imageName: "cover1",
              fileName: "movie3")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Movies"
        
        table.dataSource = self
        table.delegate = self
        
        // Se estiver usando células padrão do tipo Subtitle no Storyboard,
        // configure a célula com "cell" como Identifier, e estilo = "Subtitle"
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Identificador "cell" configurado no Storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let movie = movies[indexPath.row]
        // Título
        cell.textLabel?.text = movie.name
        
        // Subtítulo (ex: "2010 • Christopher Nolan")
        cell.detailTextLabel?.text = "\(movie.releaseYear) • \(movie.directorName)"
        
        // Se você tiver a imagem de capa no Assets (ex: "inceptionCover"):
        cell.imageView?.image = UIImage(named: movie.imageName)
        
        // Acessório de seta (opcional)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let movie = movies[indexPath.row]
        
        // Tenta encontrar o arquivo no Bundle.
        // Se for .mov, use "mov". Se for .mp4, use "mp4" etc.
        // Exemplo: "movie1.mov", "movie2.mov", "movie3.mov"
        guard let path = Bundle.main.path(forResource: movie.fileName, ofType: "mov") else {
            print("Arquivo de vídeo não encontrado no Bundle.")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        // Cria o player e o playerViewController
        let player = AVPlayer(url: url)
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        
        // Apresenta o player (modal)
        present(playerVC, animated: true) {
            player.play()
        }
    }
}
