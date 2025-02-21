import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var table: UITableView!
    
    var songs = [Song]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If you're using a Navigation Controller, give this screen a title.
        title = "Songs"
        
        // Configure song list
        configureSongs()
        
        // TableView Setup
        table.delegate = self
        table.dataSource = self
    }

    func configureSongs() {
        // Example songs. Make sure you have these mp3 files in your bundle.
        songs = [
            Song(name: "CAJU",
                 albumName: "Caju",
                 artistName: "Liniker",
                 imageName: "cover1",
                 trackName: "song1"),
            Song(name: "Abracadabra",
                 albumName: "Abracadabra",
                 artistName: "Camilla Cabello",
                 imageName: "cover2",
                 trackName: "song2"),
            Song(name: "911",
                 albumName: "Can You Keep a Secret? - EP",
                 artistName: "Lady Gaga",
                 imageName: "cover3",
                 trackName: "song3")
        ]
    }

    // MARK: - TableView Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Use the prototype cell in the storyboard with identifier "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let song = songs[indexPath.row]
        cell.textLabel?.text = song.name
        cell.detailTextLabel?.text = song.albumName
        cell.imageView?.image = UIImage(named: song.imageName)

        // Optional: Tweak fonts
        cell.textLabel?.font = UIFont(name: "Helvetica-Bold", size: 18)
        cell.detailTextLabel?.font = UIFont(name: "Helvetica", size: 15)

        // Show disclosure indicator if you prefer
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    // Optional: Make rows a bit taller for bigger images
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let position = indexPath.row
        // Instantiate our PlayerViewController from the storyboard
        guard let vc = storyboard?.instantiateViewController(identifier: "player") as? PlayerViewController else {
            return
        }
        // Pass in the songs array and current index
        vc.songs = songs
        vc.position = position

        // If you have a navigation controller, push it. Otherwise, present modally.
        navigationController?.pushViewController(vc, animated: true)
        // present(vc, animated: true)  // Alternatively
    }
}


