import 'package:get_it/get_it.dart';
import 'package:club_fitness/config/local/db_helper.dart';
import 'package:club_fitness/config/network/api.dart';
import 'features/admin_utils/admin_utils.dart';
import 'features/image_cache/image_cache.dart';
import 'features/auth/auth.dart';
import 'features/home/home.dart';
import 'features/member_manager/member_manager.dart';
import 'features/workout_manager/workout_manager.dart';
import 'features/offers/offers.dart';

GetIt sl = GetIt.instance;

void initDep() {
  _initCommon();
  _initImageCacheDep();
  _initAuthDep();
  _initHomeDep();
  _initMemberManagerDep();
  _initAdminUtilsDep();
  _initWorkoutManagerDep();
  _initOffersDep();
}

void _initCommon() {
  sl
    ..registerLazySingleton<DioConfig>(() => DioConfig())
    ..registerLazySingleton<DBHelper>(() => DBHelper());
}

// START OF _initImageCacheDep
void _initImageCacheDep() {
  ///* Service Locator Implementation for ImageCache *///
  sl
    ..registerFactory<CacheImageDataSource>(
      () => CacheImageDataSourceImpl(sl()),
    )
    ..registerFactory<CacheImageRepository>(
      () => CacheImageRepositoryImpl(sl()),
    )
    ..registerFactory<ClearAllCache>(() => ClearAllCache(sl()))
    ..registerFactory<ClearOldCache>(() => ClearOldCache(sl()))
    ..registerFactory<DeleteAllImages>(() => DeleteAllImages(sl()))
    ..registerFactory<DeleteImage>(() => DeleteImage(sl()))
    ..registerFactory<GetImage>(() => GetImage(sl()))
    ..registerFactory<GetImages>(() => GetImages(sl()))
    ..registerFactory<GetOrDownloadImage>(() => GetOrDownloadImage(sl()))
    ..registerFactory<SaveImage>(() => SaveImage(sl()))
    ..registerFactory<UpdateImage>(() => UpdateImage(sl()));
}

// START OF _initAuthDep
void _initAuthDep() {
  ///* Service Locator Implementation for Auth *///
  sl
    ..registerFactory<AuthNetworkDataSource>(
      () => AuthNetworkDataSourceImpl(sl()),
    )
    ..registerFactory<AuthRepo>(() => AuthRepoImpl(sl()))
    ..registerFactory<GetMyProfile>(() => GetMyProfile(sl()))
    ..registerFactory<Login>(() => Login(sl()))
    ..registerFactory<Logout>(() => Logout(sl()))
    ..registerFactory<LogoutAll>(() => LogoutAll(sl()))
    ..registerFactory<Register>(() => Register(sl()))
    ..registerFactory<SignInWithEmailRequestOtp>(
      () => SignInWithEmailRequestOtp(sl()),
    )
    ..registerFactory<SignInWithEmailVerifyOtp>(
      () => SignInWithEmailVerifyOtp(sl()),
    )
    ..registerFactory<SignInWithGoogle>(() => SignInWithGoogle(sl()))
    ..registerFactory<SignInWithPhoneRequestOtp>(
      () => SignInWithPhoneRequestOtp(sl()),
    )
    ..registerFactory<SignInWithPhoneVerifyOtp>(
      () => SignInWithPhoneVerifyOtp(sl()),
    );
}
// END OF _initAuthDep

// START OF _initHomeDep
void _initHomeDep() {
  ///* Service Locator Implementation for Home *///
  sl
    ..registerFactory<HomeNetworkDataSource>(
      () => HomeNetworkDataSourceImpl(sl()),
    )
    ..registerFactory<HomeRepo>(() => HomeRepoImpl(sl()))
    ..registerFactory<GetHomeData>(() => GetHomeData(sl()));
}
// END OF _initHomeDep

// START OF _initMemberManagerDep
void _initMemberManagerDep() {
  ///* Service Locator Implementation for MemberManager *///
  sl
    ..registerFactory<MemberManagerNetworkDataSource>(
      () => MemberManagerNetworkDataSourceImpl(sl()),
    )
    ..registerFactory<MemberManagerRepo>(() => MemberManagerRepoImpl(sl()))
    ..registerFactory<CreateMember>(() => CreateMember(sl()))
    ..registerFactory<CreateMembershipPlan>(() => CreateMembershipPlan(sl()))
    ..registerFactory<DeleteMember>(() => DeleteMember(sl()))
    ..registerFactory<DeleteMembershipPlan>(() => DeleteMembershipPlan(sl()))
    ..registerFactory<GetMemberDetails>(() => GetMemberDetails(sl()))
    ..registerFactory<GetMemberList>(() => GetMemberList(sl()))
    ..registerFactory<GetPlans>(() => GetPlans(sl()))
    ..registerFactory<GetTrainers>(() => GetTrainers(sl()))
    ..registerFactory<ReactivateMember>(() => ReactivateMember(sl()))
    ..registerFactory<RenewMembership>(() => RenewMembership(sl()))
    ..registerFactory<RevertLastRenewal>(() => RevertLastRenewal(sl()))
    ..registerFactory<SuspendMember>(() => SuspendMember(sl()))
    ..registerFactory<UpdateMember>(() => UpdateMember(sl()))
    ..registerFactory<UpdateMembershipPlan>(() => UpdateMembershipPlan(sl()));
}
// END OF _initMemberManagerDep

// START OF _initAdminUtilsDep
void _initAdminUtilsDep() {
  ///* Service Locator Implementation for AdminUtils *///
  sl
    ..registerFactory<AdminUtilsNetworkDataSource>(
      () => AdminUtilsNetworkDataSourceImpl(sl()),
    )
    ..registerFactory<AdminUtilsRepo>(() => AdminUtilsRepoImpl(sl()))
    ..registerFactory<ApproveFees>(() => ApproveFees(sl()))
    ..registerFactory<AttachReceipt>(() => AttachReceipt(sl()))
    ..registerFactory<CreateFee>(() => CreateFee(sl()))
    ..registerFactory<DeleteFee>(() => DeleteFee(sl()))
    ..registerFactory<ExportFeesPdf>(() => ExportFeesPdf(sl()))
    ..registerFactory<ExportSalesReportExcel>(
      () => ExportSalesReportExcel(sl()),
    )
    ..registerFactory<ExportSalesReportPdf>(() => ExportSalesReportPdf(sl()))
    ..registerFactory<GetFees>(() => GetFees(sl()))
    ..registerFactory<GetFeeById>(() => GetFeeById(sl()))
    ..registerFactory<GetFeeSummary>(() => GetFeeSummary(sl()))
    ..registerFactory<GetSalesReport>(() => GetSalesReport(sl()))
    ..registerFactory<GetSalesReportParams>(() => GetSalesReportParams(sl()))
    ..registerFactory<MarkFeePaid>(() => MarkFeePaid(sl()))
    ..registerFactory<RejectFees>(() => RejectFees(sl()))
    ..registerFactory<UpdateFee>(() => UpdateFee(sl()))
    ..registerFactory<WaiveFee>(() => WaiveFee(sl()));
}
// END OF _initAdminUtilsDep

// START OF _initWorkoutManagerDep
void _initWorkoutManagerDep() {
  ///* Service Locator Implementation for WorkoutManager *///
  sl
    ..registerFactory<WorkoutManagerNetworkDataSource>(
      () => WorkoutManagerNetworkDataSourceImpl(sl()),
    )
    ..registerFactory<WorkoutManagerRepo>(() => WorkoutManagerRepoImpl(sl()))
    ..registerFactory<AssignWorkout>(() => AssignWorkout(sl()))
    ..registerFactory<CreateExercise>(() => CreateExercise(sl()))
    ..registerFactory<CreateWorkoutPlan>(() => CreateWorkoutPlan(sl()))
    ..registerFactory<DeleteTemplate>(() => DeleteTemplate(sl()))
    ..registerFactory<DeleteTemplateParams>(() => DeleteTemplateParams(sl()))
    ..registerFactory<DeleteWorkoutPlan>(() => DeleteWorkoutPlan(sl()))
    ..registerFactory<GetAllPlans>(() => GetAllPlans(sl()))
    ..registerFactory<GetExercises>(() => GetExercises(sl()))
    ..registerFactory<GetExerciseDetails>(() => GetExerciseDetails(sl()))
    ..registerFactory<GetPlanDetails>(() => GetPlanDetails(sl()))
    ..registerFactory<GetTemplateDetails>(() => GetTemplateDetails(sl()))
    ..registerFactory<GetWorkoutTemplates>(() => GetWorkoutTemplates(sl()))
    ..registerFactory<SaveTemplate>(() => SaveTemplate(sl()))
    ..registerFactory<UpdateExercise>(() => UpdateExercise(sl()));
}

// END OF _initWorkoutManagerDep

// START OF _initOffersDep
void _initOffersDep() {
  ///* Service Locator Implementation for Offers *///
  sl
    ..registerFactory<OffersNetworkDataSource>(
      () => OffersNetworkDataSourceImpl(sl()),
    )
    ..registerFactory<OffersRepo>(() => OffersRepoImpl(sl()))
    ..registerFactory<CreateOffer>(() => CreateOffer(sl()))
    ..registerFactory<DeleteOffer>(() => DeleteOffer(sl()))
    ..registerFactory<GetOffers>(() => GetOffers(sl()))
    ..registerFactory<UpdateOffer>(() => UpdateOffer(sl()));
}

// END OF _initOffersDep
