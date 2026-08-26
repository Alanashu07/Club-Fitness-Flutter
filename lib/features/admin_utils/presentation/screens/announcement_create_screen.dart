import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

enum AnnouncementType { announcement, offer, event, alert, motivation }

enum AudienceType { all, planTier, individual, staff }

class _ChannelConfig {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  bool enabled;
  _ChannelConfig({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    this.enabled = false,
  });
}

class _MemberChip {
  final String id;
  final String name;
  final String initials;
  final Color color;
  bool selected = false;
  _MemberChip({
    required this.id,
    required this.name,
    required this.initials,
    required this.color,
  });
}

// ─── Data ─────────────────────────────────────────────────────────────────────

final _typeConfigs = [
  (
    AnnouncementType.announcement,
    'Announcement',
    Icons.campaign_rounded,
    const Color(0xFF29B6F6),
  ),
  (
    AnnouncementType.offer,
    'Offer',
    Icons.local_offer_rounded,
    const Color(0xFFFFD600),
  ),
  (
    AnnouncementType.event,
    'Event',
    Icons.event_rounded,
    const Color(0xFF4CAF50),
  ),
  (
    AnnouncementType.alert,
    'Alert',
    Icons.warning_amber_rounded,
    const Color(0xFFFFA000),
  ),
  (
    AnnouncementType.motivation,
    'Motivation',
    Icons.emoji_events_rounded,
    AppTheme.primary,
  ),
];

final _channels = [
  _ChannelConfig(
    id: 'push',
    label: 'Push Notification',
    icon: Icons.notifications_rounded,
    color: const Color(0xFF29B6F6),
    enabled: true,
  ),
  _ChannelConfig(
    id: 'whatsapp',
    label: 'WhatsApp',
    icon: Icons.chat_rounded,
    color: const Color(0xFF4CAF50),
    enabled: true,
  ),
  _ChannelConfig(
    id: 'sms',
    label: 'SMS',
    icon: Icons.sms_rounded,
    color: const Color(0xFFFFA000),
  ),
];

final _planTiers = [
  'Basic Monthly',
  'Premium Monthly',
  'Quarterly',
  'Annual Plan',
  'Trial',
];

final _memberPool = [
  _MemberChip(
    id: 'CF-001',
    name: 'Arjun Menon',
    initials: 'AM',
    color: const Color(0xFFC41E2D),
  ),
  _MemberChip(
    id: 'CF-002',
    name: 'Priya Nair',
    initials: 'PN',
    color: const Color(0xFF7B1FA2),
  ),
  _MemberChip(
    id: 'CF-003',
    name: 'Rahul Das',
    initials: 'RD',
    color: const Color(0xFF1565C0),
  ),
  _MemberChip(
    id: 'CF-004',
    name: 'Sneha Pillai',
    initials: 'SP',
    color: const Color(0xFF2E7D32),
  ),
  _MemberChip(
    id: 'CF-005',
    name: 'Kiran Kumar',
    initials: 'KK',
    color: const Color(0xFFE65100),
  ),
  _MemberChip(
    id: 'CF-006',
    name: 'Deepa Suresh',
    initials: 'DS',
    color: const Color(0xFF4E342E),
  ),
  _MemberChip(
    id: 'CF-007',
    name: 'Amal Jose',
    initials: 'AJ',
    color: const Color(0xFF37474F),
  ),
  _MemberChip(
    id: 'CF-008',
    name: 'Maya Thomas',
    initials: 'MT',
    color: const Color(0xFF00838F),
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class AnnouncementCreateScreen extends StatefulWidget {
  const AnnouncementCreateScreen({super.key});
  @override
  State<AnnouncementCreateScreen> createState() =>
      _AnnouncementCreateScreenState();
}

class _AnnouncementCreateScreenState extends State<AnnouncementCreateScreen>
    with TickerProviderStateMixin {
  // Content
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  AnnouncementType _type = AnnouncementType.announcement;

  // Audience
  AudienceType _audience = AudienceType.all;
  final Set<String> _selectedTiers = {};
  String _memberSearch = '';

  // Schedule
  bool _isScheduled = false;
  DateTime _scheduleDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _scheduleTime = TimeOfDay.now();

  // Offer extras (visible when type == offer)
  bool _hasExpiry = false;
  DateTime _offerExpiry = DateTime.now().add(const Duration(days: 7));
  final _discountCtrl = TextEditingController();

  // Animations
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  // Preview
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _titleCtrl.addListener(() => setState(() {}));
    _bodyCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  // Computed
  Color get _typeColor {
    final cfg = _typeConfigs.firstWhere((t) => t.$1 == _type);
    return cfg.$4;
  }

  IconData get _typeIcon {
    final cfg = _typeConfigs.firstWhere((t) => t.$1 == _type);
    return cfg.$3;
  }

  String get _typeLabel {
    final cfg = _typeConfigs.firstWhere((t) => t.$1 == _type);
    return cfg.$2;
  }

  int get _enabledChannelCount => _channels.where((c) => c.enabled).length;

  int get _selectedMemberCount => _memberPool.where((m) => m.selected).length;

  bool get _canPublish =>
      _titleCtrl.text.trim().isNotEmpty &&
      _bodyCtrl.text.trim().isNotEmpty &&
      _enabledChannelCount > 0;

  String get _audienceSummary {
    switch (_audience) {
      case AudienceType.all:
        return 'All Members (${_memberPool.length})';
      case AudienceType.planTier:
        return _selectedTiers.isEmpty
            ? 'No tiers selected'
            : '${_selectedTiers.length} plan tier(s)';
      case AudienceType.individual:
        return _selectedMemberCount == 0
            ? 'No members selected'
            : '$_selectedMemberCount member(s)';
      case AudienceType.staff:
        return 'All Staff';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // ── Type selector ──────────────────────────────────
                        _sectionLabel('Type'),
                        const SizedBox(height: 12),
                        _buildTypeSelector(),
                        const SizedBox(height: 24),

                        // ── Content ────────────────────────────────────────
                        _sectionLabel('Content'),
                        const SizedBox(height: 12),
                        _buildTitleField(),
                        const SizedBox(height: 12),
                        _buildBodyField(),

                        // Offer extras
                        if (_type == AnnouncementType.offer) ...[
                          const SizedBox(height: 12),
                          _buildOfferExtras(),
                        ],

                        const SizedBox(height: 24),

                        // ── Preview card ───────────────────────────────────
                        _buildPreviewToggle(),
                        if (_showPreview) ...[
                          const SizedBox(height: 12),
                          _buildPreviewCard(),
                        ],
                        const SizedBox(height: 24),

                        // ── Delivery Channels ──────────────────────────────
                        _sectionLabel('Delivery Channels'),
                        const SizedBox(height: 4),
                        Text(
                          '$_enabledChannelCount channel(s) active',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildChannels(),
                        const SizedBox(height: 24),

                        // ── Audience ───────────────────────────────────────
                        _sectionLabel('Audience'),
                        const SizedBox(height: 4),
                        Text(
                          _audienceSummary,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAudienceSelector(),

                        // Audience sub-options
                        if (_audience == AudienceType.planTier) ...[
                          const SizedBox(height: 12),
                          _buildPlanTierPicker(),
                        ],
                        if (_audience == AudienceType.individual) ...[
                          const SizedBox(height: 12),
                          _buildMemberPicker(),
                        ],

                        const SizedBox(height: 24),

                        // ── Schedule ───────────────────────────────────────
                        _sectionLabel('Send Time'),
                        const SizedBox(height: 12),
                        _buildScheduleToggle(),
                        if (_isScheduled) ...[
                          const SizedBox(height: 12),
                          _buildSchedulePicker(),
                        ],

                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Announcement',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Create and send to members',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Draft save button
            GestureDetector(
              onTap: () => _showSnack('Draft saved'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withAOpacity(0.08),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Save Draft',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Type Selector ────────────────────────────────────────────────────────────
  Widget _buildTypeSelector() {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _typeConfigs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final cfg = _typeConfigs[i];
          final selected = _type == cfg.$1;
          final color = cfg.$4;
          return GestureDetector(
            onTap: () => setState(() => _type = cfg.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              constraints: const BoxConstraints(minWidth: 100),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected ? color.withAOpacity(0.14) : AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? color.withAOpacity(0.6)
                      : Colors.white.withAOpacity(0.07),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    cfg.$3,
                    color: selected ? color : AppTheme.textSecondary,
                    size: 20,
                  ),
                  Text(
                    cfg.$2,
                    style: TextStyle(
                      color: selected ? Colors.white : AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Title Field ──────────────────────────────────────────────────────────────
  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Title'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _titleCtrl.text.isNotEmpty
                  ? _typeColor.withAOpacity(0.4)
                  : Colors.white.withAOpacity(0.07),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 50,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.white.withAOpacity(0.06),
                      width: 1,
                    ),
                  ),
                ),
                child: Center(
                  child: Icon(_typeIcon, color: _typeColor, size: 18),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _titleCtrl,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLength: 80,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Holiday Hours — June 15',
                    hintStyle: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    counterText: '',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  '${_titleCtrl.text.length}/80',
                  style: TextStyle(
                    color: _titleCtrl.text.length == 80
                        ? AppTheme.error
                        : _titleCtrl.text.length > 70
                        ? AppTheme.warning
                        : Colors.white.withAOpacity(0.2),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Body Field ───────────────────────────────────────────────────────────────
  Widget _buildBodyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Message'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _bodyCtrl.text.isNotEmpty
                  ? _typeColor.withAOpacity(0.25)
                  : Colors.white.withAOpacity(0.07),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              TextField(
                controller: _bodyCtrl,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
                maxLines: 5,
                minLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText:
                      'Write your message here. Be clear and concise — members will see this in their notification and app inbox.',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                  counterText: '',
                ),
              ),
              // Toolbar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white10, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    // Quick inserts
                    ...[
                      ('📢', '📢 '),
                      ('🎉', '🎉 '),
                      ('🔥', '🔥 '),
                      ('✅', '✅ '),
                      ('⚠️', '⚠️ '),
                    ].map(
                      (e) => GestureDetector(
                        onTap: () {
                          final text = _bodyCtrl.text + (e.$2);
                          _bodyCtrl.value = TextEditingValue(
                            text: text,
                            selection: TextSelection.collapsed(
                              offset: text.length,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            e.$1,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_bodyCtrl.text.length}/500',
                      style: TextStyle(
                        color: _bodyCtrl.text.length > 490
                            ? AppTheme.error
                            : _bodyCtrl.text.length > 400
                            ? AppTheme.warning
                            : Colors.white.withAOpacity(0.2),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Offer Extras ─────────────────────────────────────────────────────────────
  Widget _buildOfferExtras() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1200),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFD600).withAOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.local_offer_rounded,
                color: Color(0xFFFFD600),
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Offer Details',
                style: TextStyle(
                  color: Color(0xFFFFD600),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Discount field
          _fieldLabel('Discount / Offer Label (optional)'),
          const SizedBox(height: 6),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _discountCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'e.g. 20% OFF Annual Plan',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  Icons.percent_rounded,
                  color: AppTheme.textSecondary,
                  size: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Expiry toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Set Expiry Date',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Offer auto-hides after this date',
                      style: TextStyle(
                        color: Colors.white.withAOpacity(0.35),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _hasExpiry,
                onChanged: (v) => setState(() => _hasExpiry = v),
                activeThumbColor: const Color(0xFFFFD600),
                inactiveTrackColor: Colors.white12,
                inactiveThumbColor: Colors.grey,
              ),
            ],
          ),
          if (_hasExpiry) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _offerExpiry,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (_, child) => Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Color(0xFFFFD600),
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (d != null) setState(() => _offerExpiry = d);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFFD600).withAOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.event_rounded,
                      color: Color(0xFFFFD600),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Expires: ${_offerExpiry.day}/${_offerExpiry.month}/${_offerExpiry.year}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Tap to change',
                      style: TextStyle(
                        color: Colors.white.withAOpacity(0.3),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Preview Toggle ────────────────────────────────────────────────────────────
  Widget _buildPreviewToggle() {
    return GestureDetector(
      onTap: () => setState(() => _showPreview = !_showPreview),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAOpacity(0.07), width: 1),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.preview_rounded,
              color: AppTheme.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 10),
            const Text(
              'Preview Notification',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            AnimatedRotation(
              turns: _showPreview ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                Icons.expand_more_rounded,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Preview Card ─────────────────────────────────────────────────────────────
  Widget _buildPreviewCard() {
    final title = _titleCtrl.text.isEmpty ? 'Your Title' : _titleCtrl.text;
    final body = _bodyCtrl.text.isEmpty
        ? 'Your message will appear here…'
        : _bodyCtrl.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Push notification preview
        _previewSectionLabel('Push Notification'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAOpacity(0.1), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _typeColor.withAOpacity(0.18),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(_typeIcon, color: _typeColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Club Fitness',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'now',
                          style: TextStyle(
                            color: Colors.white.withAOpacity(0.3),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withAOpacity(0.55),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // In-app card preview
        _previewSectionLabel('In-App Inbox Card'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _typeColor.withAOpacity(0.25), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _typeColor.withAOpacity(0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(_typeIcon, color: _typeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Just now',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // WhatsApp preview
        if (_channels[1].enabled) ...[
          const SizedBox(height: 12),
          _previewSectionLabel('WhatsApp Message'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1F0E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF4CAF50).withAOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withAOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        color: Color(0xFF4CAF50),
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Club Fitness',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A3620),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '*$title*',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '— Club Fitness Team 💪',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _previewSectionLabel(String t) => Text(
    t,
    style: TextStyle(
      color: Colors.white.withAOpacity(0.35),
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
  );

  // ── Channels ─────────────────────────────────────────────────────────────────
  Widget _buildChannels() {
    return Column(
      children: _channels.map((ch) {
        return GestureDetector(
          onTap: () => setState(() => ch.enabled = !ch.enabled),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: ch.enabled ? ch.color.withAOpacity(0.08) : AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: ch.enabled
                    ? ch.color.withAOpacity(0.45)
                    : Colors.white.withAOpacity(0.06),
                width: ch.enabled ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ch.enabled
                        ? ch.color.withAOpacity(0.14)
                        : Colors.white.withAOpacity(0.05),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    ch.icon,
                    color: ch.enabled ? ch.color : AppTheme.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ch.label,
                        style: TextStyle(
                          color: ch.enabled
                              ? Colors.white
                              : AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _channelSubtitle(ch.id),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Toggle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ch.enabled ? ch.color : Colors.transparent,
                    border: Border.all(
                      color: ch.enabled
                          ? ch.color
                          : Colors.white.withAOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: ch.enabled
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _channelSubtitle(String id) {
    switch (id) {
      case 'push':
        return 'Instant notification on member\'s phone';
      case 'whatsapp':
        return 'Via WhatsApp Business API';
      case 'sms':
        return 'Text message to registered number';
      default:
        return '';
    }
  }

  // ── Audience Selector ────────────────────────────────────────────────────────
  Widget _buildAudienceSelector() {
    final options = [
      (
        AudienceType.all,
        'All Members',
        Icons.people_alt_rounded,
        AppTheme.primary,
      ),
      (
        AudienceType.planTier,
        'By Plan',
        Icons.card_membership_rounded,
        const Color(0xFF7B1FA2),
      ),
      (
        AudienceType.individual,
        'Individual',
        Icons.person_search_rounded,
        const Color(0xFF29B6F6),
      ),
      (
        AudienceType.staff,
        'Staff Only',
        Icons.badge_rounded,
        const Color(0xFF4CAF50),
      ),
    ];

    return Row(
      children: options.asMap().entries.map((e) {
        final i = e.key;
        final opt = e.value;
        final selected = _audience == opt.$1;
        final color = opt.$4;
        final isLast = i == options.length - 1;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _audience = opt.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(right: isLast ? 0 : 10),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
              decoration: BoxDecoration(
                color: selected ? color.withAOpacity(0.12) : AppTheme.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? color.withAOpacity(0.5)
                      : Colors.white.withAOpacity(0.06),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    opt.$3,
                    color: selected ? color : AppTheme.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    opt.$2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected ? Colors.white : AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Plan Tier Picker ─────────────────────────────────────────────────────────
  Widget _buildPlanTierPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _planTiers.map((tier) {
        final sel = _selectedTiers.contains(tier);
        return GestureDetector(
          onTap: () => setState(() {
            sel ? _selectedTiers.remove(tier) : _selectedTiers.add(tier);
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: sel
                  ? const Color(0xFF7B1FA2).withAOpacity(0.14)
                  : AppTheme.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: sel
                    ? const Color(0xFF7B1FA2).withAOpacity(0.55)
                    : Colors.white.withAOpacity(0.07),
                width: sel ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (sel)
                  const Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: Icon(
                      Icons.check_rounded,
                      color: Color(0xFF7B1FA2),
                      size: 13,
                    ),
                  ),
                Text(
                  tier,
                  style: TextStyle(
                    color: sel ? Colors.white : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Individual Member Picker ─────────────────────────────────────────────────
  Widget _buildMemberPicker() {
    final filtered = _memberPool
        .where(
          (m) =>
              _memberSearch.isEmpty ||
              m.name.toLowerCase().contains(_memberSearch.toLowerCase()),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected chips row
        if (_memberPool.any((m) => m.selected)) ...[
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: _memberPool
                  .where((m) => m.selected)
                  .map(
                    (m) => Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: m.color.withAOpacity(0.14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: m.color.withAOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            m.initials,
                            style: TextStyle(
                              color: m.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            m.name.split(' ').first,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () => setState(() => m.selected = false),
                            child: Icon(
                              Icons.close_rounded,
                              color: m.color,
                              size: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
        ],
        // Search
        _SearchBar(
          hint: 'Search members…',
          onChanged: (v) => setState(() => _memberSearch = v),
        ),
        const SizedBox(height: 10),
        // List
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withAOpacity(0.05),
              width: 1,
            ),
          ),
          child: Column(
            children: filtered.asMap().entries.map((e) {
              final i = e.key;
              final m = e.value;
              final isLast = i == filtered.length - 1;
              return GestureDetector(
                onTap: () => setState(() => m.selected = !m.selected),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: m.selected
                        ? m.color.withAOpacity(0.06)
                        : Colors.transparent,
                    border: isLast
                        ? null
                        : const Border(
                            bottom: BorderSide(
                              color: Colors.white10,
                              width: 0.5,
                            ),
                          ),
                    borderRadius: isLast
                        ? const BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: m.color.withAOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            m.initials,
                            style: TextStyle(
                              color: m.color,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          m.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: m.selected ? m.color : Colors.transparent,
                          border: Border.all(
                            color: m.selected
                                ? m.color
                                : Colors.white.withAOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: m.selected
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 12,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Schedule Toggle ───────────────────────────────────────────────────────────
  Widget _buildScheduleToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAOpacity(0.06), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _isScheduled
                  ? const Color(0xFF29B6F6).withAOpacity(0.14)
                  : Colors.white.withAOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isScheduled ? Icons.schedule_rounded : Icons.send_rounded,
              color: _isScheduled
                  ? const Color(0xFF29B6F6)
                  : AppTheme.textSecondary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isScheduled ? 'Scheduled' : 'Send Now',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _isScheduled
                      ? 'Pick a date and time to send'
                      : 'Sent immediately when you publish',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isScheduled,
            onChanged: (v) => setState(() => _isScheduled = v),
            activeThumbColor: const Color(0xFF29B6F6),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }

  // ── Schedule Picker ───────────────────────────────────────────────────────────
  Widget _buildSchedulePicker() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _scheduleDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (_, child) => Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: Color(0xFF29B6F6),
                    ),
                  ),
                  child: child!,
                ),
              );
              if (d != null) setState(() => _scheduleDate = d);
            },
            child: _ScheduleTile(
              icon: Icons.calendar_today_rounded,
              label: 'Date',
              value:
                  '${_scheduleDate.day}/${_scheduleDate.month}/${_scheduleDate.year}',
              color: const Color(0xFF29B6F6),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: _scheduleTime,
                builder: (_, child) => Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: Color(0xFF29B6F6),
                    ),
                  ),
                  child: child!,
                ),
              );
              if (t != null) setState(() => _scheduleTime = t);
            },
            child: _ScheduleTile(
              icon: Icons.access_time_rounded,
              label: 'Time',
              value: _scheduleTime.format(context),
              color: const Color(0xFF29B6F6),
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: const Border(
            top: BorderSide(color: Colors.white10, width: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Channels summary pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withAOpacity(0.07),
                  width: 1,
                ),
              ),
              child: Row(
                children:
                    _channels.where((c) => c.enabled).map((c) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(c.icon, color: c.color, size: 16),
                      );
                    }).toList()..add(
                      Padding(
                        padding: EdgeInsets.zero,
                        child: Text(
                          _enabledChannelCount == 0
                              ? 'No channels'
                              : '$_enabledChannelCount ch.',
                          style: TextStyle(
                            color: _enabledChannelCount == 0
                                ? AppTheme.error
                                : AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 12),
            // Publish button
            Expanded(
              child: GestureDetector(
                onTap: _canPublish ? _publish : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 50,
                  decoration: BoxDecoration(
                    color: _canPublish
                        ? AppTheme.primary
                        : AppTheme.primary.withAOpacity(0.3),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: _canPublish
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withAOpacity(0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isScheduled
                              ? Icons.schedule_send_rounded
                              : Icons.send_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isScheduled ? 'Schedule' : 'Send Now',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────────
  void _publish() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              _isScheduled
                  ? Icons.schedule_send_rounded
                  : Icons.check_circle_rounded,
              color: _isScheduled
                  ? const Color(0xFF29B6F6)
                  : const Color(0xFF4CAF50),
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              _isScheduled ? 'Announcement Scheduled!' : 'Announcement Sent!',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isScheduled
                  ? 'Your announcement will be sent on ${_scheduleDate.day}/${_scheduleDate.month}/${_scheduleDate.year} at ${_scheduleTime.format(context)}.'
                  : 'Your announcement has been sent to $_audienceSummary via $_enabledChannelCount channel(s).',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).maybePop();
            },
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  Widget _sectionLabel(String t) => Text(
    t,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.2,
    ),
  );

  Widget _fieldLabel(String t) => Text(
    t,
    style: const TextStyle(
      color: AppTheme.textSecondary,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    ),
  );
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _ScheduleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _ScheduleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 13),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAOpacity(0.07), width: 1),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.textSecondary,
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
