# B(D H(9/ - F8'E E9'D,) 'D#.7'!

## EB'1F) 31J9): CJA *-3QF F8'E E9'D,) 'D#.7'!

---

## L B(D 'DF8'E ('D71JB) 'DB/JE))

### AJ Cubit
```dart
Future<void> fetchData() async {
  emit(state.copyWith(isLoading: true));

  try {
    final data = await _repository.getData();
    emit(state.copyWith(isLoading: false, data: data));
  } catch (e) {
    // 13'D) .7# 9'E) H:J1 H'6-)
    emit(state.copyWith(
      isLoading: false,
      errorMessage: '-/+ .7#',  // L :J1 EAJ/ DDE3*./E
    ));
  }
}
```

### AJ Screen
```dart
BlocBuilder<MyCubit, MyState>(
  builder: (context, state) {
    if (state.isLoading) {
      return CircularProgressIndicator();
    }

    // L 916 .7# (3J7 ,/'K
    if (state.errorMessage != null) {
      return Text(
        state.errorMessage!,
        style: TextStyle(color: Colors.red),
      );
    }

    // L D' JH,/ E9'D,) D-'D) "D' *H,/ (J'F'*"
    if (state.data == null) {
      return SizedBox();  // 4'4) A'1:)!
    }

    return ListView(...);
  },
)
```

### 'DE4'CD:
- L 13'&D .7# :J1 H'6-)
- L D' JH,/ *EJJ2 (JF #FH'9 'D#.7'!
- L H',G) .7# (3J7) H:J1 '-*1'AJ)
- L D' JH,/ 21 "%9'/) 'DE-'HD)"
- L D' JH,/ E9'D,) D-'D) "D' *H,/ (J'F'*"
- L D' JH,/ /9E DDH69 'DDJDJ

---

##  (9/ 'DF8'E ('D71JB) 'D,/J/))

### AJ Cubit
```dart
import '../core/errors/app_error.dart';

Future<void> fetchData() async {
  emit(state.copyWith(isLoading: true, error: null));

  try {
    final data = await _repository.getData();
    emit(state.copyWith(isLoading: false, data: data, error: null));
  } on DioException catch (e) {
    //  *-HJD *DB'&J E9 13'&D H'6-)
    final appError = fromDioException(e);
    emit(state.copyWith(isLoading: false, error: appError));
  } catch (e) {
    //  E9'D,) #J .7# ".1
    emit(state.copyWith(
      isLoading: false,
      error: UnknownError.unexpected(e),
    ));
  }
}
```

### AJ Screen
```dart
import '../core/errors/error_handler.dart';
import '../core/widgets/error_widgets.dart';

BlocConsumer<MyCubit, MyState>(
  //  Listener D916 'D#.7'! (4CD '-*1'AJ
  listener: (context, state) {
    if (state.error != null && state.error!.severity != ErrorSeverity.critical) {
      ErrorHandler.handle(
        context: context,
        error: state.error!,
        displayType: ErrorDisplayType.snackbar,
        onRetry: () => context.read<MyCubit>().fetchData(),
      );
    }
  },

  //  Builder DDH',G)
  builder: (context, state) {
    // -'D) 'D*-EJD
    if (state.isLoading && state.data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    //  .7# -1, - 4'4) .7# C'ED) '-*1'AJ)
    if (state.error != null &&
        state.error!.severity == ErrorSeverity.critical &&
        state.data == null) {
      return ErrorScreen(
        error: state.error!,
        onRetry: () => context.read<MyCubit>().fetchData(),
      );
    }

    //  -'D) "D' *H,/ (J'F'*" - H',G) ,EJD)
    if (state.data == null || state.data!.isEmpty) {
      return EmptyStateWidget(
        title: 'D' *H,/ (J'F'*',
        message: 'DE J*E 'D9+H1 9DI #J (J'F'*',
        icon: Icons.inbox_outlined,
        onAction: () => context.read<MyCubit>().fetchData(),
        actionLabel: '*-/J+',
      );
    }

    // 916 'D(J'F'*
    return ListView(...);
  },
)
```

### 'DAH'&/:
-  13'&D .7# H'6-) HEAGHE) ('D91(J)
-  *EJJ2 (JF 7 #FH'9 EF 'D#.7'!
-  H',G'* '-*1'AJ) H,EJD)
-  21 "%9'/) 'DE-'HD)" 0CJ
-  E9'D,) C'ED) D-'D) "D' *H,/ (J'F'*"
-  /9E C'ED DDH69 'DDJDJ
-  #JBHF'* H#DH'F EF'3() DCD FH9

---

## =Ê EB'1F) *A5JDJ)

### 3JF'1JH 1: D' JH,/ '*5'D ('D%F*1F*

#### L B(D
```dart
// AJ 'DE3*./E J1I:
"-/+ .7#"  // :J1 EAJ/!

// D' JH,/:
- #JBHF)
- *A'5JD
- 21 %9'/) 'DE-'HD)
```

####  (9/
```dart
NetworkError.noInternet()

// 'DE3*./E J1I:
=ö "D' JH,/ '*5'D ('D%F*1F*"
   "J1,I 'D*-BB EF '*5'DC ('D%F*1F* H'DE-'HD) E1) #.1I"
   [21: %9'/) 'DE-'HD)]

// E9:
-  #JBHF) wifi_off
-  DHF (1*B'DJ (*-0J1)
-  13'D) H'6-)
-  *A'5JD EAJ/)
-  21 retry
```

---

### 3JF'1JH 2: .7# AJ 'D*-BB EF 'D(J'F'*

#### L B(D
```dart
// 'DE3*./E J1I:
"-/+ .7# AJ 'D(J'F'*"

// D' JH,/:
- *-/J/ 'D-BD 'D.'7&
- *A'5JD 9F 'D.7#
```

####  (9/
```dart
ValidationError.fromMap({
  'email': [''D(1J/ 'D%DC*1HFJ :J1 5-J-'],
  'password': ['CDE) 'DE1H1 B5J1) ,/'K'],
})

// 'DE3*./E J1I:
  ".7# AJ 'D(J'F'* 'DE/.D)"

   " 'D(1J/ 'D%DC*1HFJ :J1 5-J-
   " CDE) 'DE1H1 B5J1) ,/'K

// E9:
-  B'&E) (,EJ9 'D#.7'!
-  *-/J/ 'D-BHD
-  /9E field-level errors
```

---

### 3JF'1JH 3: B'&E) A'1:)

#### L B(D
```dart
// 'DE3*./E J1I:
(4'4) A'1:) *E'E'K)  // E-JQ1!

// #H:
"D' *H,/ (J'F'*"  // F5 (3J7 AB7
```

####  (9/
```dart
EmptyStateWidget(
  title: 'D' *H,/ %,'2'*',
  message: 'DE *BE (7D( #J %,'2) (9/',
  icon: Icons.event_busy,
  onAction: () => navigateToApply(),
  actionLabel: '7D( %,'2)',
)

// 'DE3*./E J1I:
=í (#JBHF) C(J1) ,EJD))
   "D' *H,/ %,'2'*"
   "DE *BE (7D( #J %,'2) (9/"
   [21: 7D( %,'2)]

// E9:
-  #JBHF) ,EJD)
-  13'D) H'6-)
-  call-to-action
```

---

## <¯ -'D'* '3*./'E E-//)

### 'D-'D) 1: *3,JD 'D-6H1 - .'1, F7'B 'DA19

#### L B(D
```dart
throw Exception('.'1, 'DF7'B');

// 916 (3J7:
Text('.'1, 'DF7'B', style: TextStyle(color: Colors.red))
```

####  (9/
```dart
throw GeofenceError.outsideBoundary(
  distance: 250.5,
  radius: 100.0,
);

// 916 '-*1'AJ:
ErrorDialog(
  error: geofenceError,
)

// 'DE3*./E J1I:
=Í ".'1, F7'B 'DA19"
   "#F* .'1, F7'B 'DA19 'DE3EH- (250E EF 100E)"

   [%:D'B]
```

---

### 'D-'D) 2: 'F*G* 'D,D3)

#### L B(D
```dart
// *3,JD .1H, *DB'&J (/HF *F(JG
// #H 13'D) 9'E)
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('-/+ .7#')),
);
```

####  (9/
```dart
throw AuthError.sessionExpired();

ErrorHandler.handle(
  context: context,
  error: authError,
  displayType: ErrorDisplayType.dialog,
);

// 'DE3*./E J1I:
= "'F*G* 'D,D3)"
   "J1,I *3,JD 'D/.HD E1) #.1I"

   [%:D'B] [*3,JD 'D/.HD]
```

---

### 'D-'D) 3: .7# 'D.'/E (500)

#### L B(D
```dart
// 13'D) *BFJ) DDE3*./E
Text('Error 500: Internal Server Error')  // L E-JQ1
```

####  (9/
```dart
throw ServerError.internal();

// 'DE3*./E J1I:
 ".7# AJ 'D.'/E"
   "-/+ .7# :J1 E*HB9. J1,I 'DE-'HD) D'-B'K"

   [%9'/) 'DE-'HD)]

// E9:
-  13'D) (3J7) HEAGHE)
-  D' *.JA 'DE3*./E
-  *H,JG H'6-
```

---

## =È 'DF*'&,

### B(D 'DF8'E:
- = *,1() E3*./E 3J&)
- >7 13'&D :J1 H'6-)
- = H',G'* (3J7)
- L D' JH,/ retry
- =É E9/D F,'- EF.A6

### (9/ 'DF8'E:
- =
 *,1() E3*./E '-*1'AJ)
-  13'&D H'6-) HEAJ/)
- <¨ H',G'* ,EJD)
- = retry 0CJ
- =È E9/D F,'- #9DI

---

## =€ '(/# 'D"F!

### .7H) H'-/) AB7:

```diff
- catch (e) {
-   emit(state.copyWith(errorMessage: '-/+ .7#'));
- }

+ on DioException catch (e) {
+   emit(state.copyWith(error: fromDioException(e)));
+ } catch (e) {
+   emit(state.copyWith(error: UnknownError.unexpected(e)));
+ }
```

### H'DF*J,):
EF 13'D) (3J7) "-/+ .7#" %DI H',G) '-*1'AJ) C'ED)! <‰

---

**1',9 'D#/D) DD*A'5JD**:
- `ERROR_HANDLING_QUICK_START.md` - DD(/! 'D31J9
- `ERROR_HANDLING_GUIDE.md` - DD#E+D) 'D*A5JDJ)
- `ERROR_HANDLING_SUMMARY.md` - DDED.5 'D4'ED
