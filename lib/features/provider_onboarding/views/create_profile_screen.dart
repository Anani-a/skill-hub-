import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/mock_state_providers.dart';
import '../providers/provider_onboarding_provider.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _businessNameCtrl;
  late TextEditingController _experienceCtrl;
  late TextEditingController _aboutCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _rateCtrl;
  late TextEditingController _newSkillCtrl;

  String _selectedEmoji = '👨‍🔧';
  String _selectedCategory = 'Home Services & Cleaning';
  List<String> _skillsList = [];

  final List<String> _categories = [
    'Home Services & Cleaning',
    'Electrical Repair',
    'Plumbing & Water',
    'Painting & Decorating',
    'Appliance Maintenance',
  ];

  final List<String> _avatarEmojis = ['👨‍🔧', '👷‍♂️', '👨‍💼', '👩‍🔧', '👨‍✈️', '👨‍💻'];

  @override
  void initState() {
    super.initState();
    final state = ref.read(providerOnboardingProvider);
    _selectedEmoji = state.profileEmoji;
    _nameCtrl = TextEditingController(text: state.providerName);
    _businessNameCtrl = TextEditingController(text: state.businessName);
    _experienceCtrl = TextEditingController(text: state.experienceYears);
    _aboutCtrl = TextEditingController(text: state.aboutText);
    _locationCtrl = TextEditingController(text: state.locationAddress);
    _rateCtrl = TextEditingController(text: state.hourlyRateEtb.toInt().toString());
    _newSkillCtrl = TextEditingController();
    _skillsList = List.from(state.skills);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _businessNameCtrl.dispose();
    _experienceCtrl.dispose();
    _aboutCtrl.dispose();
    _locationCtrl.dispose();
    _rateCtrl.dispose();
    _newSkillCtrl.dispose();
    super.dispose();
  }

  void _addSkill() {
    final text = _newSkillCtrl.text.trim();
    if (text.isNotEmpty && !_skillsList.contains(text)) {
      setState(() {
        _skillsList.add(text);
        _newSkillCtrl.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skillsList.remove(skill);
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(languageProvider);
    final notifier = ref.read(providerOnboardingProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          activeLang == 'am' ? '3. መገለጫ ይፍጠሩ' : '3. Create Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeLang == 'am' ? 'መገለጫዎን ይፍጠሩ' : 'Create your profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      activeLang == 'am'
                          ? 'ስለራስዎ እና ስራዎ ለደንበኞች ይንገሩ።'
                          : 'Tell customers about yourself and your business.',
                      style: TextStyle(fontSize: 13, color: AppTheme.textCaption),
                    ),
                    const SizedBox(height: 24),

                    // 1. Provider Profile Picture / Avatar Selector
                    _buildFieldLabel(activeLang == 'am' ? 'የመገለጫ ፎቶ / አቫታር' : 'Provider Profile Picture'),
                    const SizedBox(height: 12),
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryContainer,
                              border: Border.all(color: AppTheme.primary, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.18),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(_selectedEmoji, style: const TextStyle(fontSize: 54)),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.bgSurface, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: AppTheme.iconWhite,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Avatar Emoji Selector Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _avatarEmojis.map((emoji) {
                          final isSelected = emoji == _selectedEmoji;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedEmoji = emoji),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primary.withValues(alpha: 0.15) : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppTheme.primary : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Text(emoji, style: const TextStyle(fontSize: 24)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2. Provider Name
                    _buildFieldLabel(activeLang == 'am' ? 'የባለሙያ ስም' : 'Provider Name'),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _nameCtrl,
                      hint: 'e.g. Bekele Tadesse',
                      icon: Icons.person_outline_rounded,
                    ),

                    const SizedBox(height: 20),

                    // 3. Business Name
                    _buildFieldLabel(activeLang == 'am' ? 'የንግድ / አገልግሎት ስም' : 'Business / Service Name'),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _businessNameCtrl,
                      hint: 'e.g. Bekele Cleaning Services',
                      icon: Icons.storefront_outlined,
                    ),

                    const SizedBox(height: 20),

                    // 4. Service Category Dropdown
                    _buildFieldLabel(activeLang == 'am' ? 'የአገልግሎት ዘርፍ' : 'Service Category'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.inputBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.inputBorderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          dropdownColor: AppTheme.bgSurface,
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.iconSecondary),
                          items: _categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Row(
                                children: [
                                  Icon(Icons.grid_view_rounded, size: 20, color: AppTheme.primary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      cat,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 5. Experience & Hourly Rate Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel(activeLang == 'am' ? 'የሥራ ልምድ' : 'Experience'),
                              const SizedBox(height: 8),
                              _buildInputField(
                                controller: _experienceCtrl,
                                hint: 'e.g. 5 years',
                                icon: Icons.work_outline_rounded,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel(activeLang == 'am' ? 'የሰዓት ዋጋ (ETB)' : 'Hourly Rate (ETB)'),
                              const SizedBox(height: 8),
                              _buildInputField(
                                controller: _rateCtrl,
                                hint: '250',
                                icon: Icons.payments_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 6. Location
                    _buildFieldLabel(activeLang == 'am' ? 'አድራሻ / ቦታ' : 'Location'),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _locationCtrl,
                      hint: 'e.g. Bole, Addis Ababa',
                      icon: Icons.location_on_outlined,
                    ),

                    const SizedBox(height: 20),

                    // 7. About You
                    _buildFieldLabel(activeLang == 'am' ? 'ስለ እርሶ' : 'About You'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _aboutCtrl,
                      maxLines: 4,
                      style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: activeLang == 'am'
                            ? 'ስለ አገልግሎቶችዎ እና የሥራ ልምድዎ ይግለጹ'
                            : 'Describe your services and experience',
                        hintStyle: TextStyle(fontSize: 13, color: AppTheme.inputPlaceholder),
                        filled: true,
                        fillColor: AppTheme.inputBg,
                        contentPadding: const EdgeInsets.all(16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: AppTheme.inputBorderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: AppTheme.inputFocusColor, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 8. Skills & Certification
                    _buildFieldLabel(activeLang == 'am' ? 'ችሎታዎች እና ማረጋገጫዎች' : 'Skills & Certification'),
                    const SizedBox(height: 8),

                    // Skill pills Wrap
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skillsList.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.purple200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                skill,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _removeSkill(skill),
                                child: Icon(Icons.close_rounded, size: 16, color: AppTheme.primary),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 10),

                    // Add custom skill input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newSkillCtrl,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: activeLang == 'am' ? 'አዲስ ችሎታ ያክሉ...' : 'Add a new skill...',
                              hintStyle: TextStyle(fontSize: 12, color: AppTheme.inputPlaceholder),
                              filled: true,
                              fillColor: AppTheme.inputBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppTheme.inputBorderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppTheme.inputFocusColor, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addSkill,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.textWhite,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: Text(
                            activeLang == 'am' ? '+ ያክሉ' : '+ Add',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Bottom Action Button: Save & Continue
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryDark, AppTheme.primary, AppTheme.primaryLight],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      final rate = double.tryParse(_rateCtrl.text.trim()) ?? 250.0;
                      notifier.updateProfileInfo(
                        profileEmoji: _selectedEmoji,
                        providerName: _nameCtrl.text.trim(),
                        businessName: _businessNameCtrl.text.trim(),
                        category: _selectedCategory,
                        experience: _experienceCtrl.text.trim(),
                        about: _aboutCtrl.text.trim(),
                        location: _locationCtrl.text.trim(),
                        hourlyRate: rate,
                        skills: _skillsList,
                      );
                      context.push('/provider-onboarding-services');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      activeLang == 'am' ? 'አስቀምጥ እና ቀጥል' : 'Save & Continue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                      ),
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

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: AppTheme.inputPlaceholder),
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
        filled: true,
        fillColor: AppTheme.inputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.inputFocusColor, width: 1.5),
        ),
      ),
    );
  }
}
