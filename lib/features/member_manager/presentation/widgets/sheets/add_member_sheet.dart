import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/entities/user_entity.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/features/member_manager/member_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddMemberSheet extends StatefulWidget {
  /// When non-null the sheet works in edit mode.
  final MemberEntity? member;
  const AddMemberSheet({super.key, this.member});
  @override
  State<AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<AddMemberSheet> {
  String _selectedPlan = '';
  String _selectedTrainer = '';
  MembershipPlanMiniEntity? _selectedPlanEntity;

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _dob;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool get _isEdit => widget.member != null;

  final _picker = ImagePicker();
  XFile? _pickedImage;
  bool _removeImage = false;

  PlanOfferEntity? _selectedOffer;
  final _offerCodeCtrl = TextEditingController();

  UserRole _selectedRole = UserRole.member;

  num get _planPrice => _selectedPlanEntity?.price ?? 0;
  num get _payable => _selectedOffer?.finalAmount ?? _planPrice;

  int get _planDurationDays {
    final d = _selectedPlanEntity?.durationDays;
    return d == null ? 0 : d.toInt();
  }

  @override
  void initState() {
    super.initState();
    _refreshPlans();
    final m = widget.member;
    if (m != null) _prefill(m);
  }

  @override
  void dispose() {
    _offerCodeCtrl.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _prefill(MemberEntity m) {
    _nameController.text = m.name;
    _phoneController.text = m.phone;
    _emailController.text = m.email;
    _dob = m.dateOfBirth.isEmpty ? null : m.dateOfBirth.toDateTime;
    _selectedPlan = m.membershipPlan.id;
    _selectedTrainer = m.assignedTrainerId;
    _startDate = m.membershipStart.isEmpty
        ? null
        : m.membershipStart.toDateTime;
    _endDate = m.membershipEnd.isEmpty ? null : m.membershipEnd.toDateTime;
    _selectedRole = UserRole.member;
    _resolvePlanEntity();
  }

  // The end date picker and duration math need the plan entity, which may not
  // be loaded yet when the sheet opens.
  void _resolvePlanEntity() {
    if (_selectedPlan.isEmpty || _selectedPlanEntity != null) return;
    final plans = context.read<MembersConfigBloc>().state.membershipPlans;
    final match = plans.where((p) => p.id == _selectedPlan);
    if (match.isNotEmpty) _selectedPlanEntity = match.first;
  }

  void _refreshPlans() {
    context.read<MembersConfigBloc>().add(
      const GetMembershipPlansEvent(false, true, 'NEW_MEMBER'),
    );
  }

  // ── Selection callbacks ─────────────────────────────────────────────────

  void _onPlanPicked(MembershipPlanMiniEntity plan) {
    setState(() {
      _selectedPlan = plan.id;
      _selectedPlanEntity = plan;
      _selectedOffer = null;
      _offerCodeCtrl.clear();
      _startDate ??= DateTime.now();
      _endDate = _startDate!.add(Duration(days: plan.durationDays.toInt()));
    });
  }

  void _onPlanCleared() {
    setState(() {
      _selectedPlan = '';
      _selectedPlanEntity = null;
      _selectedOffer = null;
      _offerCodeCtrl.clear();
      _endDate = null;
    });
  }

  void _onTrainerPicked(TrainerMiniEntity trainer) {
    setState(() => _selectedTrainer = trainer.id);
  }

  void _onTrainerCleared() {
    setState(() => _selectedTrainer = '');
  }

  // ── Pickers ─────────────────────────────────────────────────────────────

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime.now(),
      firstDate: DateTime(1000),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _dob = picked);
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() {
      _startDate = picked;
      if (_selectedPlanEntity != null) {
        _endDate = picked.add(Duration(days: _planDurationDays));
      }
    });
  }

  Future<void> _pickEndDate() async {
    if (_selectedPlanEntity == null) return; // disabled until a plan is picked
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _endDate ?? DateTime.now().add(Duration(days: _planDurationDays)),
      firstDate: (_startDate ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() {
      _endDate = picked;
      _startDate = picked.subtract(Duration(days: _planDurationDays));
    });
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: Colors.white,
              ),
              title: const Text(
                'Gallery',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_camera_rounded,
                color: Colors.white,
              ),
              title: const Text(
                'Camera',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (file == null) return;
    setState(() {
      _pickedImage = file;
      _removeImage = false;
    });
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<MembersConfigBloc, MembersConfigState>(
      listener: (_, __) => setState(_resolvePlanEntity),
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: _buildForm(scrollCtrl),
        ),
      ),
    );
  }

  Widget _buildForm(ScrollController scrollCtrl) {
    return Form(
      key: _formKey,
      child: ListView(
        controller: scrollCtrl,
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        children: [
          const SheetHandle(),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAOpacity(0.15),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  _isEdit ? Icons.edit_rounded : Icons.person_add_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _isEdit ? 'Edit Member' : 'Add New Member',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPhotoPicker(),
          const SizedBox(height: 20),
          _field(
            _nameController,
            'Full Name',
            Icons.person_outline_rounded,
            hint: 'e.g. Arjun Menon',
            isRequired: true,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 14),
          _field(
            _phoneController,
            'Phone Number',
            Icons.phone_rounded,
            hint: '+91 98765 43210',
            keyboardType: TextInputType.phone,
            isRequired: true,
          ),
          const SizedBox(height: 14),
          _field(
            _emailController,
            'Email Address',
            Icons.email_outlined,
            hint: 'member@email.com',
            keyboardType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
          ),
          const SizedBox(height: 14),
          _dateField(
            label: 'Date of Birth',
            value: _dob,
            enabled: true,
            onTap: _pickDob,
          ),
          const SizedBox(height: 20),

          if (_selectedRole == UserRole.member || _isEdit) ...[
            // ── Plan (type-ahead) ──────────────────────────────────────────
            BlocBuilder<MembersConfigBloc, MembersConfigState>(
              builder: (context, state) {
                return TypeAheadSelectField<MembershipPlanMiniEntity>(
                  label: 'Membership Plan',
                  hint: 'Type to search a plan…',
                  icon: Icons.workspace_premium_outlined,
                  items: state.membershipPlans,
                  selected: _selectedPlanEntity,
                  labelOf: planLabel,
                  searchTextOf: planSearchText,
                  subtitleOf: planSubtitle,
                  onSelected: _onPlanPicked,
                  onCleared: _onPlanCleared,
                );
              },
            ),
            if (!_isEdit && _selectedPlanEntity != null) ...[
              const SizedBox(height: 20),
              OfferSelector(
                offers:
                    _selectedPlanEntity?.offers ?? const <PlanOfferEntity>[],
                selected: _selectedOffer,
                codeController: _offerCodeCtrl,
                originalPrice: _planPrice,
                onChanged: (o) => setState(() => _selectedOffer = o),
              ),
            ],
            const SizedBox(height: 20),

            // ── Trainer (type-ahead) ───────────────────────────────────────
            BlocBuilder<MembersConfigBloc, MembersConfigState>(
              builder: (context, state) {
                final selected = state.trainers
                    .where((t) => t.id == _selectedTrainer)
                    .firstOrNull;
                return TypeAheadSelectField<TrainerMiniEntity>(
                  label: 'Assign Trainer',
                  hint: 'Type to search a trainer…',
                  icon: Icons.person_outline_rounded,
                  items: state.trainers,
                  selected: selected,
                  labelOf: (t) => t.name,
                  searchTextOf: (t) => t.name,
                  onSelected: _onTrainerPicked,
                  onCleared: _onTrainerCleared,
                );
              },
            ),
            const SizedBox(height: 20),

            // ── Start / End date ───────────────────────────────────────────
            const SheetLabel('Membership Duration'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _dateField(
                    label: 'Start Date',
                    value: _startDate,
                    enabled: true,
                    onTap: _pickStartDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateField(
                    label: 'End Date',
                    value: _endDate,
                    enabled: _selectedPlanEntity != null,
                    onTap: _pickEndDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          if (!_isEdit) ...[
            const SizedBox(height: 12),
            UserRoleSelectorChip(
              selected: _selectedRole,
              onSelected: (value) => setState(() => _selectedRole = value),
            ),
          ],

          const SizedBox(height: 28),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocConsumer<MembersActionsBloc, MembersActionsState>(
      listener: (context, state) {
        if (state is CreateMemberSuccessState) {
          context.pop(
            AddMemberResult(
              member: state.member,
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              planName: _selectedPlanEntity?.name,
              planPrice: _payable.toString(),
              startDate: _startDate,
              endDate: _endDate,
            ),
          );
        } else if (state is UpdateMemberSuccessState) {
          context.pop(true);
        } else if (state is CreateMemberFailureState) {
          context.showToastFromFailure(state.failure);
        } else if (state is UpdateMemberFailureState) {
          context.showToastFromFailure(state.failure);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is CreateMemberLoadingState ||
            state is UpdateMemberLoadingState;
        return ElevatedButton(
          onPressed: isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  _isEdit ? 'Save Changes' : 'Add Member',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
        );
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPlan.isEmpty && _selectedRole == UserRole.member) {
      return _showErrorToast("Select a plan");
    }
    if (_selectedTrainer.isEmpty && _selectedRole == UserRole.member) {
      return _showErrorToast("Select a trainer");
    }
    if (_startDate == null || _endDate == null) {
      return _showErrorToast("Select membership dates");
    }
    if (_dob == null) {
      return _showErrorToast("Select date of birth");
    }

    final bloc = context.read<MembersActionsBloc>();
    if (_isEdit) {
      bloc.add(
        UpdateMemberEvent(
          id: widget.member!.id,
          name: _nameController.text.trim(),
          dob: _dob!.toIso8601String(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          plan: _selectedPlan,
          trainer: _selectedTrainer,
          startDate: _startDate!.toIso8601String(),
          profileImagePath: _pickedImage?.path,
          removeProfileImage: _removeImage,
        ),
      );
    } else {
      bloc.add(
        CreateMemberEvent(
          name: _nameController.text.trim(),
          dob: _dob!.toIso8601String(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          plan: _selectedPlan,
          trainer: _selectedTrainer,
          startDate: _startDate!.toIso8601String(),
          userRole: _selectedRole.key,
          profileImagePath: _pickedImage?.path,
          offerId: _selectedOffer?.id,
          offerCode:
              _selectedOffer == null && _offerCodeCtrl.text.trim().isNotEmpty
              ? _offerCodeCtrl.text.trim()
              : null,
        ),
      );
    }
  }

  void _showErrorToast(String message) =>
      context.showToast(message, type: ToastificationType.error);

  // ── Form pieces ─────────────────────────────────────────────────────────

  Widget _buildPhotoPicker() {
    final existing = _removeImage ? null : widget.member?.profileImageUrl;
    final hasAny = _pickedImage != null || (existing?.isNotEmpty ?? false);

    ImageProvider? provider;
    if (_pickedImage != null) {
      provider = FileImage(File(_pickedImage!.path));
    } else if (existing != null && existing.isNotEmpty) {
      provider = NetworkImage(existing);
    }

    return Row(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.cardBorder),
              image: provider == null
                  ? null
                  : DecorationImage(image: provider, fit: BoxFit.cover),
            ),
            child: provider == null
                ? const Icon(
                    Icons.add_a_photo_rounded,
                    color: AppTheme.textSecondary,
                    size: 24,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SheetLabel('Profile Photo (optional)'),
              const SizedBox(height: 6),
              Row(
                children: [
                  TextButton(
                    onPressed: _pickImage,
                    child: Text(
                      hasAny ? 'Change' : 'Upload',
                      style: const TextStyle(color: AppTheme.primary),
                    ),
                  ),
                  if (hasAny)
                    TextButton(
                      onPressed: () => setState(() {
                        _pickedImage = null;
                        _removeImage =
                            true; // tells the API to delete the stored image
                      }),
                      child: const Text(
                        'Remove',
                        style: TextStyle(color: AppTheme.error),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SheetLabel(label),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: sheetFieldDecoration().copyWith(
              color: enabled
                  ? AppTheme.surface
                  : AppTheme.surface.withAOpacity(0.4),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 15,
                  color: enabled
                      ? AppTheme.textSecondary
                      : AppTheme.textSecondary.withAOpacity(0.35),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value != null
                        ? formatShortDate(value)
                        : (enabled ? 'Select date' : 'Select a plan first'),
                    style: TextStyle(
                      color: enabled
                          ? Colors.white
                          : Colors.white.withAOpacity(0.3),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    String hint = '',
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool isRequired = false,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SheetLabel(isRequired ? '$label *' : label),
        const SizedBox(height: 8),
        Container(
          decoration: sheetFieldDecoration(),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization,
            validator: (value) {
              if (!isRequired) return null;
              if (value == null) return null;
              if (value.isEmpty) return '$label is required';
              return null;
            },
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}