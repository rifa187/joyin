import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joyin/chat/chat_message.dart';
import 'package:joyin/providers/package_provider.dart';
import 'package:joyin/providers/chat_provider.dart';
import 'package:joyin/widgets/locked_feature_widget.dart';
import 'package:provider/provider.dart';
import '../package/package_theme.dart';
import '../widgets/typing_text.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _cardSlide;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _cardSlide = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 1, curve: Curves.easeOutBack),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 1, curve: Curves.easeOut),
      ),
    );
    _contentFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 1, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _handleSend(ChatProvider chatProvider) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    await chatProvider.sendMessage(text);
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final packageProvider = context.watch<PackageProvider>();
    final bool hasPackage =
        packageProvider.currentUserPackage != null && packageProvider.currentUserPackage!.isNotEmpty;
    final packageTheme = PackageThemeResolver.resolve(packageProvider.currentUserPackage);
    final accent = packageTheme.accent;

    final double topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: packageTheme.backgroundGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroSection(topPadding, packageTheme),
              Transform.translate(
                offset: const Offset(0, -80),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(_cardSlide),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.12),
                          blurRadius: 28,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: hasPackage
                        ? FadeTransition(
                            opacity: _contentFade,
                            child: SlideTransition(
                              position: _contentSlide,
                              child: _buildChatBody(
                                accent,
                                chatProvider.messages,
                                chatProvider,
                              ),
                            ),
                          )
                        : const LockedFeatureWidget(
                            title: 'Fitur Terkunci',
                            message: 'Upgrade paketmu untuk membuka halaman Obrolan dan fitur terkait.',
                            icon: Icons.chat_bubble_outline,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(double topPadding, PackageTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding + 48, 24, 120),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.headerGradient,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TypingText(
            text: 'Obrolan',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
            duration: const Duration(milliseconds: 900),
            delay: const Duration(milliseconds: 80),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Text(
              'Pantau percakapan pelanggan, balas cepat, dan sinkronkan semua channel di satu tempat.',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBody(
    Color accent,
    List<ChatMessage> messages,
    ChatProvider chatProvider,
  ) {
    return Column(
      children: [
        const SizedBox(height: 12),
        _buildHeaderTile(accent),
        const SizedBox(height: 16),
        _buildAnimatedCard(
          messages.isEmpty
              ? _buildEmptyState(accent)
              : _buildConversation(accent, messages, chatProvider.isSending),
        ),
        const SizedBox(height: 14),
        _buildAnimatedCard(_buildQuickActions(accent)),
        const SizedBox(height: 14),
        _buildAnimatedCard(_buildFilters(accent)),
        const SizedBox(height: 20),
        _buildAnimatedCard(_buildCTA(accent, chatProvider)),
        if (chatProvider.error != null) ...[
          const SizedBox(height: 12),
          _buildErrorBanner(chatProvider.error!, accent),
        ],
      ],
    );
  }

  Widget _buildHeaderTile(Color accent) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 550),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [accent, accent.withOpacity(0.6)]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Obrolan Pelanggan', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              'Pantau percakapan, balas cepat, dan aktifkan bot untuk auto-reply.',
              style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: accent.withOpacity(0.12),
            child: Icon(Icons.chat_bubble_outline, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum ada percakapan',
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mulai obrolan baru atau hubungkan channel untuk melihat chat di sini.',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700], height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(Color accent) {
    return Row(
      children: [
        Expanded(
          child: _actionChip(
            icon: Icons.add_comment_rounded,
            label: 'Buat chat baru',
            accent: accent,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionChip(
            icon: Icons.link_rounded,
            label: 'Hubungkan channel',
            accent: accent,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionChip(
            icon: Icons.auto_awesome_rounded,
            label: 'Aktifkan bot',
            accent: accent,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _actionChip({required IconData icon, required String label, required Color accent, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(Color accent) {
    final filters = ['Semua', 'Belum dibalas', 'Butuh follow-up', 'Bot aktif'];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = filters[index];
          final selected = index == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? accent.withOpacity(0.12) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? accent : Colors.grey.shade300),
            ),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: selected ? accent : Colors.grey[700],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCTA(Color accent, ChatProvider chatProvider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Tulis pesan ke bot...',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: accent, width: 1.4),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _handleSend(chatProvider),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: accent.withOpacity(0.4),
                ),
                onPressed: chatProvider.isSending
                    ? null
                    : () => _handleSend(chatProvider),
                child: chatProvider.isSending
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(accent.computeLuminance() > 0.5
                              ? Colors.black87
                              : Colors.white),
                        ),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Tip: hubungkan WhatsApp/IG untuk menarik percakapan ke sini.',
          style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 12.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildConversation(
    Color accent,
    List<ChatMessage> messages,
    bool isSending,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 320,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg.sender == ChatSender.user;
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: const BoxConstraints(maxWidth: 260),
                    decoration: BoxDecoration(
                      color: isUser ? accent.withOpacity(0.15) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isUser ? accent.withOpacity(0.25) : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUser ? 'Kamu' : 'Bot',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isUser ? accent : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg.content,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (isSending)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 16),
                  SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Menunggu balasan...',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message, Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
    );
  }
}
