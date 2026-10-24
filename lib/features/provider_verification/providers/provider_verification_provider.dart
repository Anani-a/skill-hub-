import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProviderVerificationState {
  final bool isNationalIdUploaded;
  final bool isSelfieUploaded;
  final bool isCertificateUploaded;
  final String nationalIdName;
  final String selfieName;
  final String certificateName;
  final bool isSubmitted;
  final bool isApproved;

  const ProviderVerificationState({
    this.isNationalIdUploaded = false,
    this.isSelfieUploaded = false,
    this.isCertificateUploaded = false,
    this.nationalIdName = '',
    this.selfieName = '',
    this.certificateName = '',
    this.isSubmitted = false,
    this.isApproved = false,
  });

  ProviderVerificationState copyWith({
    bool? isNationalIdUploaded,
    bool? isSelfieUploaded,
    bool? isCertificateUploaded,
    String? nationalIdName,
    String? selfieName,
    String? certificateName,
    bool? isSubmitted,
    bool? isApproved,
  }) {
    return ProviderVerificationState(
      isNationalIdUploaded: isNationalIdUploaded ?? this.isNationalIdUploaded,
      isSelfieUploaded: isSelfieUploaded ?? this.isSelfieUploaded,
      isCertificateUploaded: isCertificateUploaded ?? this.isCertificateUploaded,
      nationalIdName: nationalIdName ?? this.nationalIdName,
      selfieName: selfieName ?? this.selfieName,
      certificateName: certificateName ?? this.certificateName,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isApproved: isApproved ?? this.isApproved,
    );
  }
}

class ProviderVerificationNotifier extends StateNotifier<ProviderVerificationState> {
  ProviderVerificationNotifier() : super(const ProviderVerificationState());

  void toggleNationalId() {
    state = state.copyWith(isNationalIdUploaded: !state.isNationalIdUploaded);
  }

  void toggleSelfie() {
    state = state.copyWith(isSelfieUploaded: !state.isSelfieUploaded);
  }

  void toggleCertificate() {
    state = state.copyWith(isCertificateUploaded: !state.isCertificateUploaded);
  }

  void submitForReview() {
    state = state.copyWith(isSubmitted: true, isApproved: true);
  }
}

final providerVerificationProvider =
    StateNotifierProvider<ProviderVerificationNotifier, ProviderVerificationState>((ref) {
  return ProviderVerificationNotifier();
});
