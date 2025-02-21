import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var table: UITableView!
    
    // Array de filmes
    var movies: [Movie] = [
        Movie(name: "Inception",
              releaseYear: "2010",
              directorName: "Christopher Nolan",
              imageName: "cover1",
              fileName: "movie1"),
        
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
        
        // Se estiver usando células “Subtitle” no Storyboard,
        // defina o Reuse Identifier como "cell"
    }
    
    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Identificador "cell" no Storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let movie = movies[indexPath.row]
        
        // Título
        cell.textLabel?.text = movie.name
        
        // Subtítulo (ex: "2010 • Christopher Nolan")
        cell.detailTextLabel?.text = "\(movie.releaseYear) • \(movie.directorName)"
        
        // Imagem de capa (se tiver no Assets)
        cell.imageView?.image = UIImage(named: movie.imageName)
        
        // Setinha de detalhe
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Instancia o controlador com ID "moviePlayer"
        guard let vc = storyboard?.instantiateViewController(identifier: "moviePlayer") as? MoviePlayerViewController else {
            print("Não consegui instanciar 'moviePlayer' do storyboard")
            return
        }
        
        // Passa os filmes e o índice selecionado
        vc.movies = movies
        vc.position = indexPath.row
        
        // Faz push (precisa de Navigation Controller)
        navigationController?.pushViewController(vc, animated: true)
    }
}
