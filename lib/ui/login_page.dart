import 'package:flutter/material.dart';

import '../logic/login_logic.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginLogic _logic = LoginLogic();
  bool _isArabic = true;
  bool _isLoading = false;
  bool _showPassword = false;

  Future<void> _handleLogin() async {
    final isLoggedIn = _logic.onLogin();
    if (!isLoggedIn) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 1500));

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HomePage(initialArabic: _isArabic)),
    );
  }

  void _toggleLanguage() {
    setState(() {
      _isArabic = !_isArabic;
    });
  }

  @override
  void dispose() {
    _logic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _isArabic
        ? const {
            'titleAr': 'إنفورم للطباعة والتصوير',
            'subtitle': 'تسجيل الدخول',
            'email': 'البريد الإلكتروني',
            'emailPlaceholder': 'أدخل البريد الإلكتروني',
            'password': 'كلمة المرور',
            'passwordPlaceholder': 'أدخل كلمة المرور',
            'loading': 'جاري تسجيل الدخول...',
            'login': 'تسجيل الدخول',
            'forgot': 'نسيت الباسوورد',
            'create': 'انشاء حساب',
          }
        : const {
            'titleAr': 'Inform Typing & Photo Copy',
            'subtitle': 'Sign In',
            'email': 'Email',
            'emailPlaceholder': 'Enter your email',
            'password': 'Password',
            'passwordPlaceholder': 'Enter your password',
            'loading': 'Signing in...',
            'login': 'Sign In',
            'forgot': 'Forgot Password',
            'create': 'Create Account',
          };

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1024;

          return Row(
            children: [
              Expanded(
                child: Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 448),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            child: OutlinedButton.icon(
                              onPressed: _toggleLanguage,
                              icon: const Icon(Icons.language, size: 16),
                              label: Text(_isArabic ? 'EN' : 'عربي'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xFFF8FAFC),
                                foregroundColor: const Color(0xFF334155),
                                side:
                                    const BorderSide(color: Color(0xFFE2E8F0)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 58),
                            child: SingleChildScrollView(
                              child: Directionality(
                                textDirection: _isArabic
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (!isDesktop) ...[
                                      Center(
                                        child: Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2563EB),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'i',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Center(
                                        child: Text(
                                          'inform typing photo copy',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                    const Text(
                                      'inform typing photo copy',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 32,
                                        height: 1.3,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n['titleAr']!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0x99334155),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: _isArabic
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Container(
                                        width: 64,
                                        height: 1,
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      l10n['subtitle']!,
                                      textAlign: _isArabic
                                          ? TextAlign.right
                                          : TextAlign.left,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    Text(
                                      l10n['email']!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: _logic.emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        hintText: l10n['emailPlaceholder'],
                                        prefixIcon: _isArabic
                                            ? null
                                            : const Icon(Icons.mail_outline,
                                                size: 18),
                                        suffixIcon: _isArabic
                                            ? const Icon(Icons.mail_outline,
                                                size: 18)
                                            : null,
                                        filled: true,
                                        fillColor: const Color(0x80F1F5F9),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Color(0x99E2E8F0)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Color(0x99E2E8F0)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      l10n['password']!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: _logic.passwordController,
                                      obscureText: !_showPassword,
                                      decoration: InputDecoration(
                                        hintText: l10n['passwordPlaceholder'],
                                        prefixIcon: _isArabic
                                            ? IconButton(
                                                onPressed: () => setState(
                                                  () => _showPassword =
                                                      !_showPassword,
                                                ),
                                                icon: Icon(
                                                  _showPassword
                                                      ? Icons
                                                          .visibility_off_outlined
                                                      : Icons
                                                          .visibility_outlined,
                                                  size: 18,
                                                ),
                                              )
                                            : const Icon(Icons.lock_outline,
                                                size: 18),
                                        suffixIcon: _isArabic
                                            ? const Icon(Icons.lock_outline,
                                                size: 18)
                                            : IconButton(
                                                onPressed: () => setState(
                                                  () => _showPassword =
                                                      !_showPassword,
                                                ),
                                                icon: Icon(
                                                  _showPassword
                                                      ? Icons
                                                          .visibility_off_outlined
                                                      : Icons
                                                          .visibility_outlined,
                                                  size: 18,
                                                ),
                                              ),
                                        filled: true,
                                        fillColor: const Color(0x80F1F5F9),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Color(0x99E2E8F0)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Color(0x99E2E8F0)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed:
                                            _isLoading ? null : _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF2563EB),
                                          foregroundColor: Colors.white,
                                          elevation: 4,
                                          shadowColor: const Color(0x402563EB),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: _isLoading
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(l10n['loading']!),
                                                ],
                                              )
                                            : Text(
                                                l10n['login']!,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(
                                          onPressed: () {},
                                          child: Text(l10n['forgot']!),
                                        ),
                                        TextButton(
                                          onPressed: () {},
                                          child: Text(l10n['create']!),
                                        ),
                                      ],
                                    ),
                                    if (!isDesktop) ...[
                                      const SizedBox(height: 20),
                                      const Divider(
                                          height: 1, color: Color(0xFFE2E8F0)),
                                      const SizedBox(height: 14),
                                      const Center(
                                        child: Text(
                                          '971 528047909 / 97155642850',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Center(
                                        child: Text(
                                          'info@informtyping.com',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Center(
                                        child: Text(
                                          'informtyping.com',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ],
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
              ),
              if (isDesktop)
                Expanded(
                  child: Container(
                    color: const Color(0xFF2563EB),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.05,
                            child: CustomPaint(painter: _GridPatternPainter()),
                          ),
                        ),
                        Positioned(
                          top: -96,
                          left: -96,
                          child: Container(
                            width: 256,
                            height: 256,
                            decoration: const BoxDecoration(
                              color: Color(0x0AFFFFFF),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -128,
                          right: -128,
                          child: Container(
                            width: 320,
                            height: 320,
                            decoration: const BoxDecoration(
                              color: Color(0x08FFFFFF),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _BrandBadge(),
                              SizedBox(height: 16),
                              Text(
                                'inform typing',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'photo copy',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xB3FFFFFF),
                                ),
                              ),
                              SizedBox(height: 30),
                              SizedBox(
                                width: 96,
                                child: Divider(
                                    color: Color(0x33FFFFFF), thickness: 1),
                              ),
                              SizedBox(height: 26),
                              _ContactItem(icon: Icons.phone_outlined, lines: [
                                '971 528047909',
                                '97155642850',
                              ]),
                              SizedBox(height: 22),
                              _ContactItem(
                                icon: Icons.mail_outline,
                                lines: ['info@informtyping.com'],
                              ),
                              SizedBox(height: 22),
                              _ContactItem(
                                icon: Icons.public,
                                lines: ['informtyping.com'],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BrandBadge extends StatelessWidget {
  const _BrandBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: const Text(
        'i',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  const _ContactItem({required this.icon, required this.lines});

  final IconData icon;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0x1AFFFFFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xCCFFFFFF), size: 20),
        ),
        const SizedBox(height: 10),
        for (final line in lines) ...[
          Text(
            line,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xE6FFFFFF),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
        ],
      ],
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const gridStep = 48.0;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += gridStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += gridStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
