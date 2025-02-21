import UIKit
import AVFoundation

class MoviePlayerViewController: UIViewController {
    
    // MARK: - Propriedades Públicas
    public var position: Int = 0
    public var movies: [Movie] = []
    
    // Shuffle (opcional, como no Player de música)
    private var isShuffleOn = false
    
    // MARK: - Player de Vídeo
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    // Timer para atualizar slider e labels
    private var timer: Timer?
    
    // MARK: - Subviews
    
    private let videoContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()
    
    private let movieTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lbl.textColor = .label
        lbl.numberOfLines = 2
        return lbl
    }()
    
    private let directorLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lbl.textColor = .lightGray
        return lbl
    }()
    
    // Slider de Progresso e labels de tempo
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
    
    // Botões de transporte
    private let backButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        btn.tintColor = .label
        return btn
    }()
    
    private let playPauseButton: UIButton = {
        let btn = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .medium)
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
    
    // Shuffle & Playlist (opcionais)
    private let shuffleButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "shuffle"), for: .normal)
        btn.tintColor = .label
        return btn
    }()
    
    private let playlistButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        btn.tintColor = .label
        return btn
    }()
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAudioSession()  // Necessário para reprodução de vídeo com som
        configurePlayer()        // Inicializa o AVPlayer
        
        setupUI()
        startTimer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ajustar o frame do playerLayer pra caber no container
        playerLayer?.frame = videoContainerView.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
        // Se quiser parar o vídeo ao sair:
        // player?.pause()
    }
    
    // MARK: - Configurações de Áudio/Vídeo
    
    private func configureAudioSession() {
        do {
            // .moviePlayback: modo adequado pra vídeo
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Falha ao configurar sessão de áudio:", error)
        }
    }
    
    private func configurePlayer() {
        guard position < movies.count else { return }
        
        let movie = movies[position]
        
        // Carregamos o vídeo do bundle (movie.fileName.mp4)
        guard let path = Bundle.main.path(forResource: movie.fileName, ofType: "mp4") else {
            print("Vídeo não encontrado no bundle.")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        // Inicializa o AVPlayer
        player = AVPlayer(url: url)
        
        // Cria uma layer que exibirá o vídeo
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        
        // Adiciona a layer ao container
        if let layer = playerLayer {
            videoContainerView.layer.addSublayer(layer)
        }
        
        // Ajusta volume inicial
        player?.volume = volumeSlider.value
        
        // Inicia a reprodução
        player?.play()
    }
    
    // MARK: - Layout da tela
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Adiciona subviews
        let subviews = [
            videoContainerView,
            movieTitleLabel,
            directorLabel,
            currentTimeLabel, progressSlider, remainingTimeLabel,
            backButton, playPauseButton, nextButton,
            volumeSlider, shuffleButton, playlistButton
        ]
        subviews.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Preenche dados do filme atual
        let movie = movies[position]
        movieTitleLabel.text = movie.name
        directorLabel.text = movie.directorName
        
        // Ações de botões
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        progressSlider.addTarget(self, action: #selector(didSlideProgress(_:)), for: .valueChanged)
        volumeSlider.addTarget(self, action: #selector(didSlideVolume(_:)), for: .valueChanged)
        shuffleButton.addTarget(self, action: #selector(didTapShuffle), for: .touchUpInside)
        playlistButton.addTarget(self, action: #selector(didTapPlaylist), for: .touchUpInside)
        
        // Constraints: exemplo simples
        NSLayoutConstraint.activate([
            // Container de vídeo na parte de cima
            videoContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            videoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            videoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            videoContainerView.heightAnchor.constraint(equalTo: videoContainerView.widthAnchor, multiplier: 0.6),
            
            // Título do filme
            movieTitleLabel.topAnchor.constraint(equalTo: videoContainerView.bottomAnchor, constant: 20),
            movieTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            movieTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Diretor
            directorLabel.topAnchor.constraint(equalTo: movieTitleLabel.bottomAnchor, constant: 8),
            directorLabel.leadingAnchor.constraint(equalTo: movieTitleLabel.leadingAnchor),
            directorLabel.trailingAnchor.constraint(equalTo: movieTitleLabel.trailingAnchor),
            
            // Tempo atual
            currentTimeLabel.topAnchor.constraint(equalTo: directorLabel.bottomAnchor, constant: 30),
            currentTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            currentTimeLabel.widthAnchor.constraint(equalToConstant: 40),
            
            // Tempo restante
            remainingTimeLabel.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor),
            remainingTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            remainingTimeLabel.widthAnchor.constraint(equalToConstant: 50),
            
            // Slider de progresso
            progressSlider.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor),
            progressSlider.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor, constant: 8),
            progressSlider.trailingAnchor.constraint(equalTo: remainingTimeLabel.leadingAnchor, constant: -8),
            
            // Botões de transporte
            playPauseButton.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: 30),
            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
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
            
            // Slider de Volume
            volumeSlider.topAnchor.constraint(equalTo: playPauseButton.bottomAnchor, constant: 30),
            volumeSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            volumeSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Shuffle
            shuffleButton.topAnchor.constraint(equalTo: volumeSlider.bottomAnchor, constant: 30),
            shuffleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            shuffleButton.widthAnchor.constraint(equalToConstant: 30),
            shuffleButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Playlist
            playlistButton.centerYAnchor.constraint(equalTo: shuffleButton.centerYAnchor),
            playlistButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            playlistButton.widthAnchor.constraint(equalToConstant: 30),
            playlistButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    // MARK: - Timer de progresso
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.5,
                                     target: self,
                                     selector: #selector(updateProgress),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc private func updateProgress() {
        guard let p = player, let item = p.currentItem else { return }
        
        let duration = CMTimeGetSeconds(item.duration)
        let current = CMTimeGetSeconds(p.currentTime())
        
        guard duration.isFinite, duration > 0 else { return }
        
        progressSlider.value = Float(current / duration)
        currentTimeLabel.text = formatTime(current)
        let remaining = duration - current
        remainingTimeLabel.text = "-" + formatTime(remaining)
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let mins = Int(interval) / 60
        let secs = Int(interval) % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    // MARK: - Botões
    
    @objc private func didTapPlayPause() {
        guard let p = player else { return }
        
        if p.timeControlStatus == .playing {
            // Pausa
            p.pause()
            let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large)
            let image = UIImage(systemName: "play.fill", withConfiguration: config)
            playPauseButton.setImage(image, for: .normal)
        } else {
            // Play
            p.play()
            let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large)
            let image = UIImage(systemName: "pause.fill", withConfiguration: config)
            playPauseButton.setImage(image, for: .normal)
        }
    }
    
    @objc private func didTapBack() {
        if isShuffleOn {
            position = Int.random(in: 0..<movies.count)
        } else {
            if position > 0 {
                position -= 1
            } else {
                position = movies.count - 1
            }
        }
        reloadPlayer()
    }
    
    @objc private func didTapNext() {
        if isShuffleOn {
            position = Int.random(in: 0..<movies.count)
        } else {
            if position < movies.count - 1 {
                position += 1
            } else {
                position = 0
            }
        }
        reloadPlayer()
    }
    
    private func reloadPlayer() {
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        
        timer?.invalidate()
        timer = nil
        
        // Configura novamente o player pro filme da nova posição
        configurePlayer()
        
        // Atualiza labels e título
        let movie = movies[position]
        movieTitleLabel.text = movie.name
        directorLabel.text = movie.directorName
        
        // Volta o botão pra "pause" (pois ao tocar, já inicia tocando)
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        
        startTimer()
    }
    
    @objc private func didSlideProgress(_ slider: UISlider) {
        guard let p = player, let item = p.currentItem else { return }
        let duration = CMTimeGetSeconds(item.duration)
        let newTime = Float64(slider.value) * duration
        
        p.seek(to: CMTime(seconds: newTime, preferredTimescale: 1)) { [weak self] _ in
            // Se estava pausado, retoma reprodução
            if p.timeControlStatus != .playing {
                p.play()
                let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large)
                let image = UIImage(systemName: "pause.fill", withConfiguration: config)
                self?.playPauseButton.setImage(image, for: .normal)
            }
        }
    }
    
    @objc private func didSlideVolume(_ slider: UISlider) {
        player?.volume = slider.value
    }
    
    @objc private func didTapShuffle() {
        isShuffleOn.toggle()
        shuffleButton.tintColor = isShuffleOn ? .systemBlue : .label
    }
    
    @objc private func didTapPlaylist() {
        let alert = UIAlertController(title: "Playlist", message: "Função não implementada.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
