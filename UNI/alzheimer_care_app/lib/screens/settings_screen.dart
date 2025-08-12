import 'package:flutter/material.dart';
import 'app_termination_screen.dart';
import '../services/api_service.dart';


class SettingsScreen extends StatefulWidget {
  final String? userName;
  
  const SettingsScreen({super.key, this.userName});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 사용자 이름을 가져오는 함수
  String get _userName {
    return widget.userName ?? '돌쇠님';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('현재 계정에서 로그아웃하시겠습니까?'),
              SizedBox(height: 8),
              Text(
                '로그아웃하면 로그인 화면으로 이동합니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await ApiService.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB74D),
                foregroundColor: Colors.white,
              ),
              child: const Text('로그아웃'),
            ),
          ],
        );
      },
    );
  }

  void _showAppTerminationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('앱 종료'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('앱을 종료하시겠습니까?'),
              SizedBox(height: 8),
              Text(
                '종료하면 가족 영상이 재생됩니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/app-termination');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('종료'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFFE65100),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8E1),
              Color(0xFFF5F5DC),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 상단 헤더
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '안녕하세요, ${_userName}님!',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE65100),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '환자 모드',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8D6E63),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB74D),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 설정 옵션들
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '앱 설정',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE65100),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 알림 설정
                          _buildSettingItem(
                            icon: Icons.notifications,
                            title: '알림 설정',
                            subtitle: '약 복용 알림 및 기타 알림',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('알림 설정 기능은 준비 중입니다.'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            },
                          ),

                          const Divider(),

                          // 소리 설정
                          _buildSettingItem(
                            icon: Icons.volume_up,
                            title: '소리 설정',
                            subtitle: '알림음 및 볼륨 조절',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('소리 설정 기능은 준비 중입니다.'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            },
                          ),

                          const Divider(),

                          // 화면 밝기
                          _buildSettingItem(
                            icon: Icons.brightness_6,
                            title: '화면 밝기',
                            subtitle: '자동 밝기 조절',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('화면 밝기 설정 기능은 준비 중입니다.'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            },
                          ),

                          const Divider(),

                          // 언어 설정
                          _buildSettingItem(
                            icon: Icons.language,
                            title: '언어 설정',
                            subtitle: '한국어',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('언어 설정 기능은 준비 중입니다.'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildSettingItem(
                            icon: Icons.link,
                            title: '앱 종료 영상 URL 설정',
                            subtitle: 'Google Drive 공유 링크 입력',
                            onTap: () async {
                              final controller = TextEditingController();
                              final url = await showDialog<String>(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title: const Text('앱 종료 영상 URL'),
                                    content: TextField(
                                      controller: controller,
                                      decoration: const InputDecoration(
                                        hintText: '예: https://drive.google.com/file/d/FILE_ID/view?usp=sharing',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('취소'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                                        child: const Text('저장'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (url != null && url.isNotEmpty) {
                                await ApiService.saveExitVideoUrl(url);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('영상 URL이 저장되었습니다.')),
                                  );
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildSettingItem(
                            icon: Icons.video_library,
                            title: '앱 종료 영상 테스트',
                            subtitle: '영상 재생 테스트',
                            onTap: () {
                              Navigator.of(context).pushNamed('/app-exit-video');
                            },
                          ),

                          const Divider(),

                          // 앱 정보
                          _buildSettingItem(
                            icon: Icons.info,
                            title: '앱 정보',
                            subtitle: '버전 1.0.0',
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('앱 정보'),
                                    content: const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('알츠하이머 케어 앱'),
                                        SizedBox(height: 8),
                                        Text('버전: 1.0.0'),
                                        Text('개발: UNI 팀'),
                                        Text('목적: 알츠하이머 환자 케어'),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('확인'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),

                          const Divider(),

                          // 로그아웃
                          _buildSettingItem(
                            icon: Icons.logout,
                            title: '로그아웃',
                            subtitle: '현재 계정에서 로그아웃',
                            onTap: () => _showLogoutDialog(context),
                            isDestructive: false,
                          ),

                          const Divider(),

                          // 앱 종료
                          _buildSettingItem(
                            icon: Icons.exit_to_app,
                            title: '앱 종료',
                            subtitle: '가족 영상과 함께 앱 종료',
                            onTap: () => _showAppTerminationDialog(context),
                            isDestructive: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // 설정 탭
        selectedItemColor: const Color(0xFFFFB74D),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index != 3) {
            Navigator.of(context).pushReplacementNamed('/home', arguments: _userName);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: '퀴즈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: '약 복용',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFFFFB74D),
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDestructive ? Colors.red.shade300 : Colors.grey,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
