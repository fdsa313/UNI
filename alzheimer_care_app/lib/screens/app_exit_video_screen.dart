import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:async';
import '../services/video_service.dart';
import '../services/api_service.dart';

class AppExitVideoScreen extends StatefulWidget {
  const AppExitVideoScreen({super.key});

  @override
  State<AppExitVideoScreen> createState() => _AppExitVideoScreenState();
}

class _AppExitVideoScreenState extends State<AppExitVideoScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoReady = false;
  bool _isVideoFinished = false;
  Timer? _exitTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final videoService = VideoService();

      // 1) 서버에서 앱 종료용 영상 가져오기 시도
      final exitVideo = await videoService.getExitVideo();

      // 2) 서버에 없으면 로컬에 저장된 URL 사용 (예: 구글 드라이브 공유 링크)
      final savedUrl = await ApiService.getExitVideoUrl();

      if (exitVideo != null && exitVideo.videoUrl.isNotEmpty) {
        print('✅ 앱 종료 영상 로드 성공: ${exitVideo.title}');
        
        // 네트워크 영상 URL로 컨트롤러 생성
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(exitVideo.videoUrl),
        );
        
        await _videoPlayerController!.initialize();
        
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: true,
          looping: false,
          showControls: false, // 컨트롤 숨김
          allowFullScreen: false,
          allowMuting: false,
          showOptions: false,
          materialProgressColors: ChewieProgressColors(
            playedColor: const Color(0xFFFFB74D),
            handleColor: const Color(0xFFFFB74D),
            backgroundColor: Colors.grey[300]!,
            bufferedColor: Colors.grey[400]!,
          ),
        );

        // 영상 재생 완료 이벤트 리스너
        _videoPlayerController!.addListener(() {
          if (_videoPlayerController!.value.position >= _videoPlayerController!.value.duration) {
            _onVideoFinished();
          }
        });

        setState(() {
          _isVideoReady = true;
        });

        // 영상 재생 시작
        await _videoPlayerController!.play();
        
      } else if (savedUrl != null && savedUrl.isNotEmpty) {
        // Google Drive 영상 재생 시도
        print('✅ 저장된 URL로 영상 재생 시도: $savedUrl');
        
        final success = await _tryPlayGoogleDriveVideo(savedUrl);
        if (!success) {
          // Google Drive 재생 실패 시 사용자에게 선택권 제공
          if (mounted) {
            final useFallback = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('영상 재생 실패'),
                content: const Text(
                  'Google Drive 영상을 재생할 수 없습니다.\n\n'
                  '샘플 영상으로 대체하시겠습니까?'
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('아니오'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('예'),
                  ),
                ],
              ),
            );
            
            if (useFallback == true) {
              // 사용자가 폴백을 선택한 경우에만 샘플 영상 재생
              await _playFallbackVideo();
            } else {
              // 사용자가 폴백을 거부한 경우 종료
              _onVideoFinished();
            }
          }
        }
      } else {
        print('❌ 앱 종료 영상을 찾을 수 없습니다');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('앱 종료 영상을 불러오지 못했습니다. 서버 설정을 확인해주세요.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        // 영상이 없으면 로딩 표시만 유지 후 3초 뒤 종료
        _onVideoFinished();
      }

    } catch (e) {
      print('❌ 영상 초기화 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('영상 로드 오류: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // 영상 로드 실패 시 바로 종료
      _onVideoFinished();
    }
  }

  // 구글 드라이브 공유 URL을 직접 파일 다운로드/재생 가능한 URL로 변환
  String _convertGoogleDriveUrl(String url) {
    // 예: https://drive.google.com/file/d/FILE_ID/view?usp=sharing
    final reg = RegExp(r"https?://drive\.google\.com/file/d/([\w-]+)/");
    final m = reg.firstMatch(url);
    if (m != null) {
      final fileId = m.group(1);
      // 웹에서 더 안정적인 재생을 위해 여러 형식 시도
      return 'https://drive.google.com/uc?export=download&id=$fileId';
    }
    // 이미 uc 링크거나 다른 CDN 링크면 그대로 사용
    return url;
  }

  // Google Drive 영상 재생 시도 (여러 방법)
  Future<bool> _tryPlayGoogleDriveVideo(String url) async {
    try {
      // 방법 1: 기본 변환된 URL로 시도
      final playableUrl = _convertGoogleDriveUrl(url);
      print('🔍 Google Drive 영상 재생 시도 1: $playableUrl');
      
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(playableUrl));
      await _videoPlayerController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        showControls: false,
        allowFullScreen: false,
        allowMuting: false,
        showOptions: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFFFB74D),
          handleColor: const Color(0xFFFFB74D),
          backgroundColor: Colors.grey[300]!,
          bufferedColor: Colors.grey[400]!,
        ),
      );

      setState(() {
        _isVideoReady = true;
      });
      
      await _videoPlayerController!.play();
      return true;
      
    } catch (e) {
      print('❌ Google Drive 영상 재생 실패: $e');
      
      // 방법 2: 다른 형식의 URL로 재시도
      try {
        final reg = RegExp(r"https?://drive\.google\.com/file/d/([\w-]+)/");
        final m = reg.firstMatch(url);
        if (m != null) {
          final fileId = m.group(1);
          final alternativeUrl = 'https://drive.google.com/file/d/$fileId/preview';
          print('🔍 Google Drive 영상 재생 시도 2: $alternativeUrl');
          
          _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(alternativeUrl));
          await _videoPlayerController!.initialize();
          
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: true,
            looping: false,
            showControls: false,
            allowFullScreen: false,
            allowMuting: false,
            showOptions: false,
            materialProgressColors: ChewieProgressColors(
              playedColor: const Color(0xFFFFB74D),
              handleColor: const Color(0xFFFFB74D),
              backgroundColor: Colors.grey[300]!,
              bufferedColor: Colors.grey[400]!,
            ),
          );

          setState(() {
            _isVideoReady = true;
          });
          
          await _videoPlayerController!.play();
          return true;
        }
      } catch (e2) {
        print('❌ Google Drive 영상 재생 시도 2도 실패: $e2');
      }
      
      return false;
    }
  }

  // 안전한 샘플 영상 재생 (대체 영상)
  Future<void> _playFallbackVideo() async {
    try {
      const fallbackUrl = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
      print('🔁 샘플 URL로 재생 시도: $fallbackUrl');
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(fallbackUrl));
      await _videoPlayerController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        showControls: false,
        allowFullScreen: false,
        allowMuting: false,
        showOptions: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFFFB74D),
          handleColor: const Color(0xFFFFB74D),
          backgroundColor: Colors.grey[300]!,
          bufferedColor: Colors.grey[400]!,
        ),
      );
      setState(() {
        _isVideoReady = true;
      });
      await _videoPlayerController!.play();
    } catch (e) {
      print('❌ 샘플 영상 재생 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('영상 로드 오류: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _onVideoFinished();
    }
  }

  void _onVideoFinished() {
    if (!_isVideoFinished) {
      setState(() {
        _isVideoFinished = true;
      });
      
      // 3초 후 앱 종료
      _exitTimer = Timer(const Duration(seconds: 3), () {
        _exitApp();
      });
    }
  }

  void _exitApp() {
    // 웹에서는 강제 종료 불가 → 홈으로 이동
    if (Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS) {
      // 모바일은 종료 시도 (플랫폼 채널로 처리 가능). 여기서는 이전 화면으로 pop만 수행
      Navigator.of(context).maybePop();
    } else {
      // 웹/데스크탑: 홈으로 이동
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: _isVideoReady
              ? _buildVideoPlayer()
              : _buildLoadingIndicator(),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_chewieController != null) {
      return Stack(
        children: [
          // 영상 플레이어
          Chewie(controller: _chewieController!),
          
          // 영상 완료 후 메시지
          if (_isVideoFinished)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFFFFB74D),
                      size: 80,
                    ),
                    SizedBox(height: 20),
                    Text(
                      '안전하게 앱을 종료합니다',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '잠시만 기다려주세요...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    } else {
      return const Text(
        '영상을 불러올 수 없습니다',
        style: TextStyle(color: Colors.white),
      );
    }
  }

  Widget _buildLoadingIndicator() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: Color(0xFFFFB74D),
        ),
        SizedBox(height: 20),
        Text(
          '영상을 준비하고 있습니다...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
