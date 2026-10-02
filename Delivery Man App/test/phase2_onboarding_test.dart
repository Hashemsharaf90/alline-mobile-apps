import 'package:flutter_test/flutter_test.dart';
import 'package:sixvalley_delivery_boy/features/auth/domain/models/response_model.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/domain/models/driver_onboarding_model.dart';
import 'package:sixvalley_delivery_boy/utill/app_constants.dart';

void main() {
  group('Phase 2 Driver Onboarding & Approval Unit Tests', () {
    test('AppConstants contains all verified Onboarding API endpoints', () {
      expect(AppConstants.driverRegisterUri, '/api/v2/delivery-man/auth/register');
      expect(AppConstants.driverVerifyRegistrationOtpUri, '/api/v2/delivery-man/auth/verify-registration-otp');
      expect(AppConstants.driverResendRegistrationOtpUri, '/api/v2/delivery-man/auth/resend-registration-otp');
      expect(AppConstants.driverOnboardingProfileUri, '/api/v2/delivery-man/onboarding/profile');
      expect(AppConstants.driverOnboardingDocumentsUri, '/api/v2/delivery-man/onboarding/documents');
      expect(AppConstants.driverOnboardingVehicleUri, '/api/v2/delivery-man/onboarding/vehicle');
      expect(AppConstants.driverOnboardingLocationUri, '/api/v2/delivery-man/onboarding/location');
      expect(AppConstants.driverOnboardingSubmitUri, '/api/v2/delivery-man/onboarding/submit');
      expect(AppConstants.driverOnboardingStatusUri, '/api/v2/delivery-man/onboarding/status');
      expect(AppConstants.driverApprovalStatus, 'driver_approval_status');
    });

    test('CandidateDriver deserializes and serializes accurately', () {
      final json = {
        'id': 101,
        'f_name': 'Ali',
        'l_name': 'Ahmed',
        'phone': '770000000',
        'country_code': '+967',
        'full_phone': '+967770000000',
        'email': 'ali@test.com',
        'address': 'Hadda St, Sanaa',
        'identity_type': 'passport',
        'identity_number': 'P98765432',
        'latitude': 15.3694,
        'longitude': 44.1910,
        'approval_status': 'pending_approval',
        'review_note': 'Documents received, awaiting inspection',
        'application_submitted_at': '2026-10-02T01:00:00.000Z',
        'is_active': 0,
      };

      final driver = CandidateDriver.fromJson(json);

      expect(driver.id, 101);
      expect(driver.fName, 'Ali');
      expect(driver.lName, 'Ahmed');
      expect(driver.phone, '770000000');
      expect(driver.approvalStatus, 'pending_approval');
      expect(driver.reviewNote, 'Documents received, awaiting inspection');
      expect(driver.latitude, 15.3694);
      expect(driver.longitude, 44.1910);
      expect(driver.isActive, 0);

      final exported = driver.toJson();
      expect(exported['id'], 101);
      expect(exported['identity_number'], 'P98765432');
      expect(exported['approval_status'], 'pending_approval');
    });

    test('DriverVehicle serializes and deserializes accurately', () {
      final json = {
        'id': 5,
        'vehicle_type': 'motorcycle',
        'brand_or_model': 'Honda CG 125',
        'plate_number': '1234-A',
        'color': 'Black',
        'is_active': 1,
      };

      final vehicle = DriverVehicle.fromJson(json);

      expect(vehicle.id, 5);
      expect(vehicle.vehicleType, 'motorcycle');
      expect(vehicle.brandOrModel, 'Honda CG 125');
      expect(vehicle.plateNumber, '1234-A');
      expect(vehicle.color, 'Black');
      expect(vehicle.isActive, 1);

      final map = vehicle.toJson();
      expect(map['vehicle_type'], 'motorcycle');
      expect(map['plate_number'], '1234-A');
    });

    test('OnboardingDocument deserializes correctly', () {
      final json = {
        'id': 12,
        'document_type': 'national_id_front',
        'file_path': 'driver/doc12.png',
        'file_url': 'http://localhost/storage/driver/doc12.png',
        'review_status': 'approved',
        'review_note': 'Clear document',
      };

      final doc = OnboardingDocument.fromJson(json);

      expect(doc.id, 12);
      expect(doc.documentType, 'national_id_front');
      expect(doc.filePath, 'driver/doc12.png');
      expect(doc.reviewStatus, 'approved');
      expect(doc.reviewNote, 'Clear document');
    });

    test('OnboardingStepStatus parses completion flags accurately', () {
      final json = {
        'phone_verified': true,
        'profile_completed': true,
        'documents_completed': true,
        'has_identity_doc': true,
        'has_license_doc': true,
        'vehicle_completed': true,
        'location_completed': true,
        'can_submit': true,
      };

      final steps = OnboardingStepStatus.fromJson(json);

      expect(steps.phoneVerified, true);
      expect(steps.profileCompleted, true);
      expect(steps.documentsCompleted, true);
      expect(steps.hasIdentityDoc, true);
      expect(steps.hasLicenseDoc, true);
      expect(steps.vehicleCompleted, true);
      expect(steps.locationCompleted, true);
      expect(steps.canSubmit, true);
    });

    test('DriverOnboardingStatusResponse parses full backend payload', () {
      final json = {
        'delivery_man_id': 88,
        'f_name': 'Rashid',
        'l_name': 'Nasser',
        'phone': '771234567',
        'approval_status': 'pending_approval',
        'is_active': 0,
        'review_note': 'In queue for admin review',
        'application_submitted_at': '2026-10-02T01:10:00.000Z',
        'documents': [
          {
            'id': 1,
            'document_type': 'driver_license_front',
            'file_path': 'driver/dl.png',
            'review_status': 'pending',
          }
        ],
        'vehicle': {
          'id': 3,
          'vehicle_type': 'car',
          'brand_or_model': 'Toyota Yaris',
          'plate_number': '7788-C',
          'color': 'Silver',
        },
        'location': {
          'latitude': 15.3500,
          'longitude': 44.2000,
        }
      };

      final response = DriverOnboardingStatusResponse.fromJson(json);

      expect(response.deliveryManId, 88);
      expect(response.fName, 'Rashid');
      expect(response.approvalStatus, 'pending_approval');
      expect(response.isActive, 0);
      expect(response.documents?.length, 1);
      expect(response.vehicle?.brandOrModel, 'Toyota Yaris');
      expect(response.location?['latitude'], 15.3500);
    });

    test('ResponseModel accurately conveys approval status and review note', () {
      final responseSuccess = ResponseModel(
        true,
        'successful',
        approvalStatus: 'pending_approval',
        reviewNote: 'Pending verification',
      );

      expect(responseSuccess.isSuccess, true);
      expect(responseSuccess.approvalStatus, 'pending_approval');
      expect(responseSuccess.reviewNote, 'Pending verification');

      final responseRejected = ResponseModel(
        false,
        'account_rejected',
        approvalStatus: 'account_rejected',
        reviewNote: 'Invalid national ID document',
      );

      expect(responseRejected.isSuccess, false);
      expect(responseRejected.approvalStatus, 'account_rejected');
      expect(responseRejected.reviewNote, 'Invalid national ID document');
    });
  });
}
