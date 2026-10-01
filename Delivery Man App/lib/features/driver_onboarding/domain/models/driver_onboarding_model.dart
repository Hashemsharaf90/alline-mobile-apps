class CandidateDriver {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? countryCode;
  String? fullPhone;
  String? email;
  String? address;
  String? identityType;
  String? identityNumber;
  String? image;
  String? imageUrl;
  double? latitude;
  double? longitude;
  String? approvalStatus;
  String? reviewNote;
  DateTime? applicationSubmittedAt;
  int? isActive;

  CandidateDriver({
    this.id,
    this.fName,
    this.lName,
    this.phone,
    this.countryCode,
    this.fullPhone,
    this.email,
    this.address,
    this.identityType,
    this.identityNumber,
    this.image,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.approvalStatus,
    this.reviewNote,
    this.applicationSubmittedAt,
    this.isActive,
  });

  factory CandidateDriver.fromJson(Map<String, dynamic> json) {
    return CandidateDriver(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      fName: json['f_name'],
      lName: json['l_name'],
      phone: json['phone'],
      countryCode: json['country_code'],
      fullPhone: json['full_phone'],
      email: json['email'],
      address: json['address'],
      identityType: json['identity_type'],
      identityNumber: json['identity_number'],
      image: json['image'],
      imageUrl: json['image_url'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      approvalStatus: json['approval_status'] ?? 'draft',
      reviewNote: json['review_note'],
      applicationSubmittedAt: json['application_submitted_at'] != null ? DateTime.tryParse(json['application_submitted_at'].toString()) : null,
      isActive: json['is_active'] is int ? json['is_active'] : int.tryParse(json['is_active']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'f_name': fName,
      'l_name': lName,
      'phone': phone,
      'country_code': countryCode,
      'full_phone': fullPhone,
      'email': email,
      'address': address,
      'identity_type': identityType,
      'identity_number': identityNumber,
      'image': image,
      'image_url': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'approval_status': approvalStatus,
      'review_note': reviewNote,
      'application_submitted_at': applicationSubmittedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }
}

class DriverVehicle {
  int? id;
  String? vehicleType;
  String? brandOrModel;
  String? plateNumber;
  String? color;
  String? registrationDocumentPath;
  String? registrationDocumentUrl;
  int? isActive;

  DriverVehicle({
    this.id,
    this.vehicleType,
    this.brandOrModel,
    this.plateNumber,
    this.color,
    this.registrationDocumentPath,
    this.registrationDocumentUrl,
    this.isActive,
  });

  factory DriverVehicle.fromJson(Map<String, dynamic> json) {
    return DriverVehicle(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      vehicleType: json['vehicle_type'],
      brandOrModel: json['brand_or_model'],
      plateNumber: json['plate_number'],
      color: json['color'],
      registrationDocumentPath: json['registration_document_path'],
      registrationDocumentUrl: json['registration_document_url'],
      isActive: json['is_active'] is int ? json['is_active'] : int.tryParse(json['is_active']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_type': vehicleType,
      'brand_or_model': brandOrModel,
      'plate_number': plateNumber,
      'color': color,
      'registration_document_path': registrationDocumentPath,
      'registration_document_url': registrationDocumentUrl,
      'is_active': isActive,
    };
  }
}

class OnboardingDocument {
  int? id;
  String? documentType;
  String? filePath;
  String? fileUrl;
  String? reviewStatus;
  String? reviewNote;
  DateTime? createdAt;

  OnboardingDocument({
    this.id,
    this.documentType,
    this.filePath,
    this.fileUrl,
    this.reviewStatus,
    this.reviewNote,
    this.createdAt,
  });

  factory OnboardingDocument.fromJson(Map<String, dynamic> json) {
    return OnboardingDocument(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      documentType: json['document_type'],
      filePath: json['file_path'],
      fileUrl: json['file_url'],
      reviewStatus: json['review_status'] ?? 'pending',
      reviewNote: json['review_note'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document_type': documentType,
      'file_path': filePath,
      'file_url': fileUrl,
      'review_status': reviewStatus,
      'review_note': reviewNote,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class OnboardingStepStatus {
  bool phoneVerified;
  bool profileCompleted;
  bool documentsCompleted;
  bool hasIdentityDoc;
  bool hasLicenseDoc;
  bool vehicleCompleted;
  bool locationCompleted;
  bool canSubmit;

  OnboardingStepStatus({
    this.phoneVerified = false,
    this.profileCompleted = false,
    this.documentsCompleted = false,
    this.hasIdentityDoc = false,
    this.hasLicenseDoc = false,
    this.vehicleCompleted = false,
    this.locationCompleted = false,
    this.canSubmit = false,
  });

  factory OnboardingStepStatus.fromJson(Map<String, dynamic> json) {
    return OnboardingStepStatus(
      phoneVerified: json['phone_verified'] == true,
      profileCompleted: json['profile_completed'] == true,
      documentsCompleted: json['documents_completed'] == true,
      hasIdentityDoc: json['has_identity_doc'] == true,
      hasLicenseDoc: json['has_license_doc'] == true,
      vehicleCompleted: json['vehicle_completed'] == true,
      locationCompleted: json['location_completed'] == true,
      canSubmit: json['can_submit'] == true,
    );
  }
}

class DriverOnboardingProfileResponse {
  CandidateDriver? deliveryMan;
  DriverVehicle? vehicle;
  List<OnboardingDocument>? documents;
  OnboardingStepStatus? steps;

  DriverOnboardingProfileResponse({
    this.deliveryMan,
    this.vehicle,
    this.documents,
    this.steps,
  });

  factory DriverOnboardingProfileResponse.fromJson(Map<String, dynamic> json) {
    List<OnboardingDocument> docList = [];
    if (json['documents'] != null && json['documents'] is List) {
      for (var d in json['documents']) {
        docList.add(OnboardingDocument.fromJson(d));
      }
    }

    return DriverOnboardingProfileResponse(
      deliveryMan: json['delivery_man'] != null ? CandidateDriver.fromJson(json['delivery_man']) : null,
      vehicle: json['vehicle'] != null ? DriverVehicle.fromJson(json['vehicle']) : null,
      documents: docList,
      steps: json['steps'] != null ? OnboardingStepStatus.fromJson(json['steps']) : null,
    );
  }
}

class DriverOnboardingStatusResponse {
  int? deliveryManId;
  String? fName;
  String? lName;
  String? phone;
  String? approvalStatus;
  int? isActive;
  String? reviewNote;
  DateTime? applicationSubmittedAt;
  DateTime? reviewedAt;
  List<OnboardingDocument>? documents;
  DriverVehicle? vehicle;
  Map<String, dynamic>? location;

  DriverOnboardingStatusResponse({
    this.deliveryManId,
    this.fName,
    this.lName,
    this.phone,
    this.approvalStatus,
    this.isActive,
    this.reviewNote,
    this.applicationSubmittedAt,
    this.reviewedAt,
    this.documents,
    this.vehicle,
    this.location,
  });

  factory DriverOnboardingStatusResponse.fromJson(Map<String, dynamic> json) {
    List<OnboardingDocument> docList = [];
    if (json['documents'] != null && json['documents'] is List) {
      for (var d in json['documents']) {
        docList.add(OnboardingDocument.fromJson(d));
      }
    }

    return DriverOnboardingStatusResponse(
      deliveryManId: json['delivery_man_id'] is int ? json['delivery_man_id'] : int.tryParse(json['delivery_man_id']?.toString() ?? ''),
      fName: json['f_name'],
      lName: json['l_name'],
      phone: json['phone'],
      approvalStatus: json['approval_status'] ?? 'draft',
      isActive: json['is_active'] is int ? json['is_active'] : int.tryParse(json['is_active']?.toString() ?? '0') ?? 0,
      reviewNote: json['review_note'],
      applicationSubmittedAt: json['application_submitted_at'] != null ? DateTime.tryParse(json['application_submitted_at'].toString()) : null,
      reviewedAt: json['reviewed_at'] != null ? DateTime.tryParse(json['reviewed_at'].toString()) : null,
      documents: docList,
      vehicle: json['vehicle'] != null ? DriverVehicle.fromJson(json['vehicle']) : null,
      location: json['location'] is Map<String, dynamic> ? json['location'] : null,
    );
  }
}
