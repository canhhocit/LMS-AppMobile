import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class AppVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final bool preventFastForward;
  final VoidCallback? onVideoCompleted;

  const AppVideoPlayer({
    super.key,
    required this.videoUrl,
    this.title,
    this.preventFastForward = true,
    this.onVideoCompleted,
  });

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorDetail = '';
  bool _showControls = true;
  bool _hasTriggeredCompletion = false;

  // Track max watched position to prevent skipping ahead
  Duration _maxWatchedPosition = Duration.zero;
  double _currentSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant AppVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeAndReinitialize();
    }
  }

  Future<void> _disposeAndReinitialize() async {
    await _controller?.dispose();
    _controller = null;
    if (mounted) {
      setState(() {
        _isInitialized = false;
        _hasError = false;
        _maxWatchedPosition = Duration.zero;
        _hasTriggeredCompletion = false;
      });
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    try {
      final uri = Uri.parse(widget.videoUrl);
      final controller = VideoPlayerController.networkUrl(uri);
      _controller = controller;

      await controller.initialize();
      controller.addListener(_videoListener);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _hasError = true;
          _errorDetail = e.toString();
        });
      }
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null || !_controller!.value.isInitialized) return;

    final value = _controller!.value;
    final currentPos = value.position;
    final totalDuration = value.duration;

    // 1. Anti-Fast-Forward Check (Chống tua trước)
    if (widget.preventFastForward) {
      // If user seeks past max watched position (+ 3 seconds threshold)
      if (currentPos > _maxWatchedPosition + const Duration(seconds: 3)) {
        _controller!.seekTo(_maxWatchedPosition);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Bạn cần xem tuần tự bài giảng, không được tua nhanh trước!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    // Update max watched position as video plays
    if (currentPos > _maxWatchedPosition) {
      _maxWatchedPosition = currentPos;
    }

    // 2. Auto-Complete trigger when watched >= 90%
    if (totalDuration > Duration.zero && !_hasTriggeredCompletion) {
      final progress = currentPos.inMilliseconds / totalDuration.inMilliseconds;
      if (progress >= 0.90) {
        _hasTriggeredCompletion = true;
        widget.onVideoCompleted?.call();
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _openExternal() async {
    final uri = Uri.parse(widget.videoUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _changeSpeed() {
    if (_controller == null || !_isInitialized) return;
    double nextSpeed = 1.0;
    if (_currentSpeed == 1.0) nextSpeed = 1.25;
    else if (_currentSpeed == 1.25) nextSpeed = 1.5;
    else if (_currentSpeed == 1.5) nextSpeed = 2.0;
    else nextSpeed = 1.0;

    _controller!.setPlaybackSpeed(nextSpeed);
    setState(() {
      _currentSpeed = nextSpeed;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 230,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: _hasError
          ? _buildErrorView()
          : !_isInitialized
              ? _buildLoadingView()
              : _buildVideoView(),
    );
  }

  Widget _buildLoadingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: AppColors.primary),
        const SizedBox(height: 12),
        Text(
          widget.title ?? 'Đang tải video bài giảng...',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    final isPluginErr = _errorDetail.contains('MissingPluginException');
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.orangeAccent, size: 40),
          const SizedBox(height: 8),
          Text(
            isPluginErr
                ? 'Vui lòng khởi động lại app để nạp trình phát video mới'
                : 'Không thể phát video trực tiếp',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            isPluginErr
                ? 'Thư viện phát video vừa được thêm cần khởi động lại app (Restart/Build) trên điện thoại để đăng ký bộ mã hóa Android.'
                : 'Vui lòng kiểm tra lại kết nối mạng hoặc thử lại.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _disposeAndReinitialize,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _openExternal,
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Mở ngoài'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoView() {
    final controller = _controller!;
    final value = controller.value;
    final isPlaying = value.isPlaying;

    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: value.aspectRatio > 0 ? value.aspectRatio : 16 / 9,
              child: VideoPlayer(controller),
            ),
          ),

          // Anti-tua Badge (Top Left)
          if (widget.preventFastForward)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Colors.orangeAccent, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Chống tua trước',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

          // Speed Control Badge (Top Right)
          Positioned(
            top: 6,
            right: 6,
            child: TextButton(
              onPressed: _changeSpeed,
              style: TextButton.styleFrom(
                backgroundColor: Colors.black54,
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                '${_currentSpeed}x',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),

          // Play / Pause toggle overlay center button
          if (_showControls)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Replay 10s
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.replay_10, color: Colors.white70),
                  onPressed: () {
                    final target = value.position - const Duration(seconds: 10);
                    controller.seekTo(target < Duration.zero ? Duration.zero : target);
                  },
                ),
                const SizedBox(width: 16),
                // Play / Pause
                IconButton(
                  iconSize: 56,
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  onPressed: () {
                    setState(() {
                      isPlaying ? controller.pause() : controller.play();
                    });
                  },
                ),
                const SizedBox(width: 16),
                // Forward 10s (Only up to max watched position)
                IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.forward_10, color: Colors.white70),
                  onPressed: () {
                    final target = value.position + const Duration(seconds: 10);
                    if (widget.preventFastForward && target > _maxWatchedPosition) {
                      controller.seekTo(_maxWatchedPosition);
                    } else {
                      controller.seekTo(target > value.duration ? value.duration : target);
                    }
                  },
                ),
              ],
            ),

          // Bottom control bar
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VideoProgressIndicator(
                      controller,
                      allowScrubbing: !widget.preventFastForward, // Lock scrubbing if anti-tua is active
                      colors: const VideoProgressColors(
                        playedColor: AppColors.primary,
                        bufferedColor: Colors.white30,
                        backgroundColor: Colors.white10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        if (_hasTriggeredCompletion)
                          const Row(
                            children: [
                              Icon(Icons.check_circle, color: AppColors.success, size: 14),
                              SizedBox(width: 4),
                              Text('Đã xem xong', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
