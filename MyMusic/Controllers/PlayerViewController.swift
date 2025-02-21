import UIKit
import AVFoundation

// Se você não usa mais isFavorite, remova esse campo do struct


class PlayerViewController: UIViewController {
    
    
    
    
    // MARK: - Propriedades Públicas
    public var position: Int = 0
    public var songs: [Song] = []
    
    // MARK: - Shuffle (caso queira manter esse recurso)
    private var isShuffleOn = false
    
    // MARK: - Áudio
    private var player: AVAudioPlayer?
    private var timer: Timer?
    
    // MARK: - Subviews
    
    private let backgroundGradient: CAGradientLayer = {
        let grad = CAGradientLayer()
        grad.colors = [
            UIColor(red: 0.09, green: 0.09, blue: 0.10, alpha: 1).cgColor, // #18181A
            UIColor(red: 0.16, green: 0.16, blue: 0.17, alpha: 1).cgColor  // #29292B
        ]
        grad.startPoint = CGPoint(x: 0, y: 0)
        grad.endPoint = CGPoint(x: 0, y: 1)
        return grad
    }()
    
    private let contentView = UIView()
    
    private let albumArtImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 10
        iv.clipsToBounds = true
        return iv
    }()
    
    private let songTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lbl.textColor = .label
        lbl.numberOfLines = 2
        return lbl
    }()
    
    private let artistLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lbl.textColor = .lightGray
        return lbl
    }()
    
    // Botão “Mais” (reticências)
    private let moreButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        btn.tintColor = .lightGray
        return btn
    }()
    
    // MARK: - Slider de Progresso e Labels de tempo
    private let progressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .label
        slider.maximumTrackTintColor = UIColor.label.withAlphaComponent(0.3)
        slider.thumbTintColor = .label
        return slider
    }()
    
    private let currentTimeLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = .lightGray
        lbl.text = "0:00"
        return lbl
    }()
    
    private let remainingTimeLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = .lightGray
        lbl.text = "-0:00"
        lbl.textAlignment = .right
        return lbl
    }()
    
    // Controles de transporte
    private let backButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        btn.tintColor = .label
        return btn
    }()
    
    private let playPauseButton: UIButton = {
        let btn = UIButton()

        // Crie uma configuração de símbolo maior
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .medium)
        // Carregue a imagem "pause.fill" com essa config
        let image = UIImage(systemName: "pause.fill", withConfiguration: config)
        
        btn.setImage(image, for: .normal)
        btn.tintColor = .label
        return btn
    }()

    
    private let nextButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        btn.tintColor = .label
        return btn
    }()
    
    // Slider de Volume
    private let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.7
        slider.minimumTrackTintColor = .label
        slider.maximumTrackTintColor = UIColor.label.withAlphaComponent(0.3)
        slider.thumbTintColor = .label
        return slider
    }()
    
    // Botão Shuffle (opcional)
    private let shuffleButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "shuffle"), for: .normal)
        btn.tintColor = .label
        return btn
    }()
    
    // Botão Playlist (opcional)
    private let playlistButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        btn.tintColor = .label
        return btn
    }()
    
    // MARK: - Ciclo de Vida
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAudioSession()
        configurePlayer()
        
        setupUI()
        startTimer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        backgroundGradient.frame = contentView.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
        // Se quiser parar a música ao sair:
        // player?.stop()
    }
    
    // MARK: - Áudio
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Falha ao configurar AVAudioSession:", error)
        }
    }
    
    private func configurePlayer() {
        guard position < songs.count else { return }
        let song = songs[position]
        
        guard let path = Bundle.main.path(forResource: song.trackName, ofType: "mp3") else {
            print("Música não encontrada.")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            // Ajusta volume inicial pelo slider
            player?.volume = volumeSlider.value
            player?.play()
        } catch {
            print("Erro ao iniciar player:", error)
        }
    }
    
    // MARK: - Layout
    
    private func setupUI() {
        // contentView
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        contentView.layer.insertSublayer(backgroundGradient, at: 0)
        
        // Subviews
        let subviews = [
            albumArtImageView,
            songTitleLabel,
            artistLabel,
            moreButton,
            currentTimeLabel, progressSlider, remainingTimeLabel,
            backButton, playPauseButton, nextButton,
            volumeSlider, shuffleButton, playlistButton
        ]
        for sub in subviews {
            contentView.addSubview(sub)
            sub.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Dados
        let song = songs[position]
        albumArtImageView.image = UIImage(named: song.imageName)
        songTitleLabel.text = song.name
        artistLabel.text = song.artistName
        
        // Targets
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        progressSlider.addTarget(self, action: #selector(didSlideProgress(_:)), for: .valueChanged)
        volumeSlider.addTarget(self, action: #selector(didSlideVolume(_:)), for: .valueChanged)
        shuffleButton.addTarget(self, action: #selector(didTapShuffle), for: .touchUpInside)
        playlistButton.addTarget(self, action: #selector(didTapPlaylist), for: .touchUpInside)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Capa do Álbum
            albumArtImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 0),
            albumArtImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            albumArtImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7),
            albumArtImageView.heightAnchor.constraint(equalTo: albumArtImageView.widthAnchor),
            
            // Título
            songTitleLabel.topAnchor.constraint(equalTo: albumArtImageView.bottomAnchor, constant: 30),
            songTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            // “mais button” no lugar do antigo favorito
            songTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: moreButton.leadingAnchor, constant: -10),
            
            // Botão “mais”
            moreButton.centerYAnchor.constraint(equalTo: songTitleLabel.centerYAnchor),
            moreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            moreButton.widthAnchor.constraint(equalToConstant: 30),
            moreButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Artista
            artistLabel.topAnchor.constraint(equalTo: songTitleLabel.bottomAnchor, constant: 6),
            artistLabel.leadingAnchor.constraint(equalTo: songTitleLabel.leadingAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Tempo atual
            currentTimeLabel.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 30),
            currentTimeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            currentTimeLabel.widthAnchor.constraint(equalToConstant: 40),
            
            // Tempo restante
            remainingTimeLabel.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor),
            remainingTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            remainingTimeLabel.widthAnchor.constraint(equalToConstant: 50),
            
            // Slider de progresso
            progressSlider.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor),
            progressSlider.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor, constant: 8),
            progressSlider.trailingAnchor.constraint(equalTo: remainingTimeLabel.leadingAnchor, constant: -8),
            
            // Controles
            playPauseButton.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: 30),
            playPauseButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 60),
            playPauseButton.heightAnchor.constraint(equalToConstant: 60),
            
            backButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            backButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -40),
            backButton.widthAnchor.constraint(equalToConstant: 50),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            
            nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            nextButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 40),
            nextButton.widthAnchor.constraint(equalToConstant: 50),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Volume
            volumeSlider.topAnchor.constraint(equalTo: playPauseButton.bottomAnchor, constant: 30),
            volumeSlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            volumeSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Shuffle
            shuffleButton.topAnchor.constraint(equalTo: volumeSlider.bottomAnchor, constant: 30),
            shuffleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 60),
            shuffleButton.widthAnchor.constraint(equalToConstant: 30),
            shuffleButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Playlist
            playlistButton.centerYAnchor.constraint(equalTo: shuffleButton.centerYAnchor),
            playlistButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -60),
            playlistButton.widthAnchor.constraint(equalToConstant: 30),
            playlistButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    // MARK: - Timer e Atualização do Slider
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.5,
                                     target: self,
                                     selector: #selector(updateProgress),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc private func updateProgress() {
        guard let p = player else { return }
        let duration = p.duration
        let current = p.currentTime
        if duration > 0 {
            progressSlider.value = Float(current / duration)
            currentTimeLabel.text = formatTime(current)
            let remaining = duration - current
            remainingTimeLabel.text = "-" + formatTime(remaining)
        }
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let mins = Int(interval) / 60
        let secs = Int(interval) % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    // MARK: - Botões
    
    @objc private func didTapPlayPause() {
        guard let player = player else { return }

        if player.isPlaying {
            // Pausa
            player.pause()
            // Reaplica a configuração
            let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large)
            let image = UIImage(systemName: "play.fill", withConfiguration: config)
            playPauseButton.setImage(image, for: .normal)
        } else {
            // Play
            player.play()
            // Reaplica a configuração
            let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large)
            let image = UIImage(systemName: "pause.fill", withConfiguration: config)
            playPauseButton.setImage(image, for: .normal)
        }
    }

    
    @objc private func didTapBack() {
        if isShuffleOn {
            position = Int.random(in: 0..<songs.count)
        } else {
            if position > 0 {
                position -= 1
            } else {
                position = songs.count - 1
            }
        }
        reloadPlayer()
    }
    
    @objc private func didTapNext() {
        if isShuffleOn {
            position = Int.random(in: 0..<songs.count)
        } else {
            if position < songs.count - 1 {
                position += 1
            } else {
                position = 0
            }
        }
        reloadPlayer()
    }
    
    private func reloadPlayer() {
        player?.stop()
        player = nil
        timer?.invalidate()
        timer = nil
        
        configurePlayer()
        
        let song = songs[position]
        albumArtImageView.image = UIImage(named: song.imageName)
        songTitleLabel.text = song.name
        artistLabel.text = song.artistName
        
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        albumArtImageView.transform = .identity
        
        startTimer()
    }
    
    @objc private func didSlideProgress(_ slider: UISlider) {
        guard let p = player else { return }
        let dur = p.duration
        let newTime = Double(slider.value) * dur
        p.currentTime = newTime
        if !p.isPlaying {
            p.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    @objc private func didSlideVolume(_ slider: UISlider) {
        player?.volume = slider.value
    }
    
    // MARK: - Shuffle
    @objc private func didTapShuffle() {
        isShuffleOn.toggle()
        shuffleButton.tintColor = isShuffleOn ? .systemBlue : .label
    }
    
    // MARK: - Playlist
    @objc private func didTapPlaylist() {
        let alert = UIAlertController(title: "Playlist", message: "Função não implementada", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Mais
    @objc private func didTapMore() {
        let alert = UIAlertController(title: "Opções", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Adicionar à Playlist", style: .default, handler: { _ in
            print("Adicionar à Playlist")
        }))
        alert.addAction(UIAlertAction(title: "Compartilhar...", style: .default, handler: { _ in
            guard self.position < self.songs.count else { return }
            let songName = self.songs[self.position].name
            let activityVC = UIActivityViewController(activityItems: ["Estou ouvindo \(songName)!"], applicationActivities: nil)
            self.present(activityVC, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        // iPad fix
        if let popover = alert.popoverPresentationController {
            popover.sourceView = moreButton
            popover.sourceRect = moreButton.bounds
        }
        
        present(alert, animated: true)
    }
}
