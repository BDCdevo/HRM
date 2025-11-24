# /DJD E9'D,) 'D#.7'! AJ *7(JB HRM

## =Ë F81) 9'E)

F8'E 4'ED DE9'D,) 'D#.7'! AJ 'D*7(JB JHA1:
-  H',G'* E3*./E '-*1'AJ) D916 'D#.7'!
-  E9'D,) EH-Q/) D,EJ9 #FH'9 'D#.7'!
-  /9E C'ED DDH69 'DDJDJ
-  13'&D .7# ('D91(J) HH'6-)
-  %EC'FJ) %9'/) 'DE-'HD) DD9EDJ'* 'DB'(D) DD%9'/)

---

## <¨ #FH'9 916 'D#.7'!

### 1. SnackBar ('D'A*1'6J)
41J7 AJ #3AD 'D4'4) - EF'3( DD#.7'! 'D(3J7)

```dart
ErrorHandler.handle(
  context: context,
  error: error,
  displayType: ErrorDisplayType.snackbar,
  onRetry: () => fetchData(),
);
```

### 2. Dialog
F'A0) EF(+B) - EF'3() DD#.7'! 'DEGE) 'D*J *-*', 'F*('G

```dart
ErrorHandler.handle(
  context: context,
  error: NetworkError.noInternet(),
  displayType: ErrorDisplayType.dialog,
  onRetry: () => retryOperation(),
);
```

### 3. Toast
%49'1 .AJA AJ #9DI 'D4'4)

```dart
ErrorHandler.handle(
  context: context,
  error: error,
  displayType: ErrorDisplayType.toast,
);
```

### 4. Full Screen
4'4) C'ED) - DD#.7'! 'D-1,) #H 9F/ A4D *-EJD 'D(J'F'* 'D#3'3J)

```dart
return ErrorScreen(
  error: appError,
  onRetry: () {
    context.read<MyCubit>().fetchData();
  },
);
```

---

## <× #FH'9 'D#.7'! 'DE/9HE)

### 1. NetworkError - #.7'! 'D4(C)
```dart
// D' JH,/ '*5'D ('D%F*1F*
NetworkError.noInternet()

// 'F*G* EGD) 'D'*5'D
NetworkError.timeout()

// D' JECF 'DH5HD DD.'/E
NetworkError.serverUnreachable()

// .7# E.55
NetworkError(
  message: 'A4D 'D'*5'D',
  details: '*A'5JD %6'AJ)',
  isRetryable: true,
)
```

### 2. AuthError - #.7'! 'DE5'/B)
```dart
// (J'F'* /.HD .'7&)
AuthError.invalidCredentials()

// 'F*G* 'D,D3)
AuthError.sessionExpired()

// :J1 E51-
AuthError.unauthorized()

// -3'( E-8H1
AuthError.accountLocked()
```

### 3. ValidationError - #.7'! 'D*-BB EF 'D(J'F'*
```dart
// EF '3*,'() API
ValidationError.fromMap({
  'email': [''D(1J/ 'D%DC*1HFJ :J1 5-J-'],
  'password': ['CDE) 'DE1H1 B5J1) ,/'K'],
})

// J/HJ'K
ValidationError(
  message: '.7# AJ 'D(J'F'*',
  details: 'J1,I 'D*-BB EF 'DE/.D'*',
  fieldErrors: {
    'email': [''D(1J/ 'D%DC*1HFJ E7DH('],
  },
)
```

### 4. ServerError - #.7'! 'D.'/E
```dart
ServerError.internal()          // 500
ServerError.serviceUnavailable() // 503
ServerError.maintenance()        // 5J'F)

ServerError(
  message: '.7# AJ 'D.'/E',
  statusCode: 500,
  isRetryable: true,
)
```

### 5. BusinessError - #.7'! EF7B 'D#9E'D
```dart
BusinessError.notFound(''D7D(')
BusinessError.alreadyExists(''D3,D')
BusinessError.notAllowed()
BusinessError.insufficientBalance()
```

### 6. PermissionError - #.7'! 'D#0HF'*
```dart
PermissionError.locationDenied()
PermissionError.locationDisabled()
PermissionError.cameraPermissionDenied()
PermissionError.storagePermissionDenied()
```

### 7. GeofenceError - #.7'! 'DEHB9 'D,:1'AJ
```dart
GeofenceError.outsideBoundary(
  distance: 250.5,
  radius: 100.0,
)
GeofenceError.noBranchAssigned()
```

---

## =ñ Widgets DD#.7'!

### 1. ErrorScreen - 4'4) .7# C'ED)
```dart
if (state is Error) {
  return ErrorScreen(
    error: state.error,
    onRetry: () => cubit.retry(),
  );
}
```

### 2. ErrorDialog - F'A0) .7# EF(+B)
```dart
showDialog(
  context: context,
  builder: (context) => ErrorDialog(
    error: NetworkError.noInternet(),
    onRetry: () => fetchData(),
  ),
);
```

### 3. InlineErrorWidget - 916 .7# /'.D 'DFEH0,
```dart
if (errorMessage != null)
  InlineErrorWidget(
    message: errorMessage,
    onRetry: () => validateForm(),
  )
```

### 4. EmptyStateWidget - -'D) 9/E H,H/ (J'F'*
```dart
if (data.isEmpty) {
  return EmptyStateWidget(
    title: 'D' *H,/ %,'2'*',
    message: 'DE *BE (7D( #J %,'2) (9/',
    icon: Icons.event_busy,
    onAction: () => navigateToApplyLeave(),
    actionLabel: '7D( %,'2)',
  );
}
```

### 5. CompactErrorWidget - .7# E/E, DDBH'&E
```dart
ListView.builder(
  itemBuilder: (context, index) {
    if (hasError) {
      return CompactErrorWidget(
        message: 'A4D *-EJD 'D9F51',
        onRetry: () => loadItem(index),
      );
    }
    return ListTile(...);
  },
)
```

---

## =' #E+D) 9EDJ) DD*C'ED

### E+'D 1: E9'D,) #.7'! Cubit

```dart
class MyFeatureCubit extends Cubit<MyFeatureState> {
  final MyRepository _repository;

  MyFeatureCubit(this._repository) : super(MyFeatureState.initial());

  Future<void> fetchData() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final data = await _repository.getData();
      emit(state.copyWith(
        isLoading: false,
        data: data,
        error: null,
      ));
    } on DioException catch (e) {
      // 'D*-HJD 'D*DB'&J EF DioException %DI AppError
      final appError = fromDioException(e);
      emit(state.copyWith(
        isLoading: false,
        error: appError,
      ));
    } catch (e) {
      // #J .7# ".1
      emit(state.copyWith(
        isLoading: false,
        error: UnknownError.unexpected(e),
      ));
    }
  }
}
```

### E+'D 2: 916 'D#.7'! AJ 'D4'4)

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('4'4) 'D(J'F'*')),
      body: BlocConsumer<MyFeatureCubit, MyFeatureState>(
        // Listener D916 'D#.7'! :J1 'D-1,)
        listener: (context, state) {
          if (state.error != null && state.error!.severity != ErrorSeverity.critical) {
            ErrorHandler.handle(
              context: context,
              error: state.error!,
              displayType: ErrorDisplayType.snackbar,
              onRetry: () => context.read<MyFeatureCubit>().fetchData(),
            );
          }
        },
        // Builder D916 UI
        builder: (context, state) {
          // Loading State
          if (state.isLoading && state.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Critical Error - Full Screen
          if (state.error != null &&
              state.error!.severity == ErrorSeverity.critical &&
              state.data == null) {
            return ErrorScreen(
              error: state.error!,
              onRetry: () => context.read<MyFeatureCubit>().fetchData(),
            );
          }

          // Empty State
          if (state.data == null || state.data!.isEmpty) {
            return EmptyStateWidget(
              title: 'D' *H,/ (J'F'*',
              message: 'DE J*E 'D9+H1 9DI #J (J'F'*',
              icon: Icons.inbox_outlined,
              onAction: () => context.read<MyFeatureCubit>().fetchData(),
              actionLabel: '*-/J+',
            );
          }

          // Success - Show Data
          return ListView.builder(
            itemCount: state.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(state.data![index].title),
              );
            },
          );
        },
      ),
    );
  }
}
```

### E+'D 3: E9'D,) #.7'! 'DFE'0,

```dart
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _emailError;
  String? _passwordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            // %0' C'F .7# *-BB EF 'D(J'F'*
            if (state.error is ValidationError) {
              final validationError = state.error as ValidationError;
              setState(() {
                _emailError = validationError.getFieldError('email');
                _passwordError = validationError.getFieldError('password');
              });
            } else {
              // #.7'! #.1I - 916 Dialog
              ErrorHandler.handle(
                context: context,
                error: state.error,
                displayType: ErrorDisplayType.dialog,
                onRetry: () => _submitLogin(),
              );
            }
          }
        },
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Email Field
              CustomTextField(
                label: ''D(1J/ 'D%DC*1HFJ',
                errorText: _emailError,
              ),

              // Password Field
              CustomTextField(
                label: 'CDE) 'DE1H1',
                errorText: _passwordError,
                isPassword: true,
              ),

              // Submit Button
              CustomButton(
                text: '*3,JD 'D/.HD',
                onPressed: _submitLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitLogin() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(email, password);
    }
  }
}
```

### E+'D 4: E9'D,) #.7'! 'DEHB9

```dart
Future<void> checkIn() async {
  emit(state.copyWith(isLoading: true));

  try {
    // 'D*-BB EF %0F 'DEHB9
    final permission = await _locationService.checkPermission();

    if (permission == LocationPermission.denied) {
      throw PermissionError.locationDenied();
    }

    if (permission == LocationPermission.deniedForever) {
      throw PermissionError(
        message: '*E 1A6 %0F 'DEHB9 FG'&J'K',
        details: 'J1,I *A9JD %0F 'DEHB9 EF %9/'/'* 'D*7(JB',
      );
    }

    // 'D*-BB EF *A9JD GPS
    final serviceEnabled = await _locationService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw PermissionError.locationDisabled();
    }

    // 'D-5HD 9DI 'DEHB9
    final position = await _locationService.getCurrentPosition();

    // 'D*-BB EF Geofence
    final distance = calculateDistance(position, branchLocation);
    if (distance > allowedRadius) {
      throw GeofenceError.outsideBoundary(
        distance: distance,
        radius: allowedRadius,
      );
    }

    // *3,JD 'D-6H1
    await _attendanceRepo.checkIn(position);

    emit(AttendanceSuccess(message: '*E *3,JD 'D-6H1 (F,'-'));

  } on AppError catch (e) {
    emit(AttendanceError(error: e));
  } catch (e) {
    emit(AttendanceError(error: UnknownError.unexpected(e)));
  }
}
```

### E+'D 5: E9'D,) #.7'! 'D*-EJD 'DE*9//

```dart
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<DashboardCubit>().fetchAllData();
        },
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            // %0' C'F* ,EJ9 'D(J'F'* A'4D)
            if (state.hasAllFailed) {
              return ErrorScreen(
                error: state.firstError!,
                onRetry: () => context.read<DashboardCubit>().fetchAllData(),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Statistics Card
                  if (state.statisticsError != null)
                    CompactErrorWidget(
                      message: 'A4D *-EJD 'D%-5'&J'*',
                      onRetry: () => context.read<DashboardCubit>().fetchStatistics(),
                    )
                  else if (state.statistics != null)
                    StatisticsCard(data: state.statistics!),

                  // Attendance Card
                  if (state.attendanceError != null)
                    CompactErrorWidget(
                      message: 'A4D *-EJD (J'F'* 'D-6H1',
                      onRetry: () => context.read<DashboardCubit>().fetchAttendance(),
                    )
                  else if (state.attendance != null)
                    AttendanceCard(data: state.attendance!),

                  // Leaves Card
                  if (state.leavesError != null)
                    InlineErrorWidget(
                      message: 'A4D *-EJD 'D%,'2'*',
                      onRetry: () => context.read<DashboardCubit>().fetchLeaves(),
                    )
                  else if (state.leaves != null)
                    LeavesCard(data: state.leaves!),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
```

---

## <¯ #A6D 'DEE'13'*

### 1. '3*./E 'DFH9 'DEF'3( EF 916 'D#.7'!

- **SnackBar**: DD#.7'! 'D(3J7) 'D*J D' *EF9 'DE3*./E EF 'D'3*E1'1
- **Dialog**: DD#.7'! 'DEGE) 'D*J *-*', 'G*E'E AH1J
- **Toast**: DD%49'1'* 'D.AJA)
- **ErrorScreen**: DD#.7'! 'D-1,) #H A4D *-EJD 'D(J'F'* 'D#3'3J)

### 2. #6A %EC'FJ) %9'/) 'DE-'HD) /'&E'K

```dart
ErrorHandler.handle(
  context: context,
  error: error,
  onRetry: error.isRetryable ? () => retryOperation() : null,
);
```

### 3. '3*./E BlocListener DD#.7'! :J1 'D-1,)

```dart
BlocListener<MyCubit, MyState>(
  listener: (context, state) {
    if (state.error != null && state.error!.severity != ErrorSeverity.critical) {
      ErrorHandler.handle(
        context: context,
        error: state.error!,
        displayType: ErrorDisplayType.snackbar,
      );
    }
  },
  child: ...,
)
```

### 4. '-*A8 ('D(J'F'* 'DB/JE) 9F/ -/H+ .7#

```dart
// L .7# - E3- 'D(J'F'*
emit(state.copyWith(
  data: null,
  error: error,
));

//  5-J- - 'D'-*A'8 ('D(J'F'*
emit(state.copyWith(
  isLoading: false,
  error: error,
  // D' *E3- data
));
```

### 5. '916 Empty State (/D'K EF 4'4) A'1:)

```dart
if (data.isEmpty) {
  return EmptyStateWidget(
    title: 'D' *H,/ (J'F'*',
    message: ''(/# (%6'A) (J'F'* ,/J/)',
    icon: Icons.inbox_outlined,
  );
}
```

### 6. '3*./E 'D*-HJD 'D*DB'&J DD#.7'!

```dart
try {
  // 9EDJ)
} on DioException catch (e) {
  // 'D*-HJD 'D*DB'&J
  final appError = fromDioException(e);
  emit(state.copyWith(error: appError));
} catch (e) {
  // #J .7# ".1
  emit(state.copyWith(error: UnknownError.unexpected(e)));
}
```

---

## = '.*('1 'D#.7'!

### '.*('1 #FH'9 'D#.7'!

```dart
// '.*('1 .7# 'D4(C)
throw NetworkError.noInternet();

// '.*('1 .7# 'DE5'/B)
throw AuthError.sessionExpired();

// '.*('1 .7# 'D*-BB
throw ValidationError.fromMap({
  'email': [''D(1J/ 'D%DC*1HFJ :J1 5-J-'],
});

// '.*('1 .7# 'D.'/E
throw ServerError.internal();

// '.*('1 .7# 'DEHB9
throw GeofenceError.outsideBoundary(
  distance: 250,
  radius: 100,
);
```

### '.*('1 916 'D#.7'!

```dart
// AJ 4'4) *,1J(J)
ElevatedButton(
  onPressed: () {
    ErrorHandler.handle(
      context: context,
      error: NetworkError.noInternet(),
      displayType: ErrorDisplayType.dialog,
      onRetry: () => print('Retry!'),
    );
  },
  child: const Text(''.*('1 .7# 'D4(C)'),
)
```

---

## =Ú EDA'* 'DF8'E

```
lib/core/
   errors/
      app_error.dart              # *91JA ,EJ9 #FH'9 'D#.7'!
      error_handler.dart          # E9'D, 'D#.7'! 'DE1C2J
      error_display_helper.dart   # E3'9/ 916 'D#.7'!
      error_boundary.dart         # -E'J) 'D*7(JB EF 'D#.7'!
   widgets/
       error_widgets.dart          # ,EJ9 widgets 'D#.7'!
```

---

## =€ 'D.D'5)

F8'E E9'D,) 'D#.7'! JHA1:

 **H',G'* '-*1'AJ)** - *5EJE'* ,EJD) */9E 'DH69 'DDJDJ
 **13'&D H'6-)** - 13'&D .7# ('D91(J) HEAGHE)
 **E9'D,) 4'ED)** - /9E ,EJ9 #FH'9 'D#.7'!
 **3GHD) 'D'3*./'E** - API (3J7 HH'6-
 **%9'/) 'DE-'HD)** - 21 retry DD9EDJ'* 'DB'(D) DD%9'/)
 **E1HF)** - .J'1'* 916 E*9//) -3( 'D-'D)

'3*./E G0' 'DF8'E AJ ,EJ9 features DD-5HD 9DI *,1() E3*./E E*3B) HE-*1A)! <‰
