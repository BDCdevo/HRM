# 'D(/'J) 'D31J9) - E9'D,) 'D#.7'!

## =€ 'D'3*./'E 'D#3'3J

### 1. AJ Cubit - E9'D,) 'D#.7'!

```dart
import 'package:dio/dio.dart';
import '../core/errors/app_error.dart';

Future<void> fetchData() async {
  emit(state.copyWith(isLoading: true, error: null));

  try {
    final data = await _repository.getData();
    emit(state.copyWith(isLoading: false, data: data));
  } on DioException catch (e) {
    final appError = fromDioException(e); // *-HJD *DB'&J
    emit(state.copyWith(isLoading: false, error: appError));
  } catch (e) {
    emit(state.copyWith(
      isLoading: false,
      error: UnknownError.unexpected(e),
    ));
  }
}
```

### 2. AJ Screen - 916 'D#.7'!

```dart
import '../core/errors/error_handler.dart';
import '../core/widgets/error_widgets.dart';

// '3*./'E BlocConsumer
BlocConsumer<MyCubit, MyState>(
  // 916 SnackBar DD#.7'! 'D(3J7)
  listener: (context, state) {
    if (state.error != null) {
      ErrorHandler.handle(
        context: context,
        error: state.error!,
        displayType: ErrorDisplayType.snackbar,
        onRetry: () => context.read<MyCubit>().fetchData(),
      );
    }
  },

  // (F'! 'DH',G)
  builder: (context, state) {
    // -'D) 'D*-EJD
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // .7# -1, - 4'4) C'ED)
    if (state.error != null && state.data == null) {
      return ErrorScreen(
        error: state.error!,
        onRetry: () => context.read<MyCubit>().fetchData(),
      );
    }

    // D' *H,/ (J'F'*
    if (state.data == null || state.data!.isEmpty) {
      return EmptyStateWidget(
        title: 'D' *H,/ (J'F'*',
        message: ''(/# (%6'A) (J'F'* ,/J/)',
        icon: Icons.inbox_outlined,
      );
    }

    // 916 'D(J'F'*
    return ListView.builder(...);
  },
)
```

---

## =ñ Widgets 'D,'G2)

### ErrorScreen - 4'4) .7# C'ED)
```dart
ErrorScreen(
  error: appError,
  onRetry: () => retry(),
)
```

### EmptyStateWidget - D' *H,/ (J'F'*
```dart
EmptyStateWidget(
  title: 'D' *H,/ %,'2'*',
  message: 'DE *BE (7D( #J %,'2) (9/',
  icon: Icons.event_busy,
  onAction: () => applyLeave(),
  actionLabel: '7D( %,'2)',
)
```

### InlineErrorWidget - .7# AJ 'DFEH0,
```dart
InlineErrorWidget(
  message: 'A4D -A8 'D(J'F'*',
  onRetry: () => save(),
)
```

### CompactErrorWidget - .7# E/E,
```dart
CompactErrorWidget(
  message: 'A4D *-EJD 'D9F51',
  onRetry: () => loadItem(),
)
```

---

## <¨ #FH'9 916 'D#.7'!

```dart
ErrorHandler.handle(
  context: context,
  error: error,
  displayType: ErrorDisplayType.snackbar,  // 41J7 #3AD 'D4'4)
  // displayType: ErrorDisplayType.dialog,  // F'A0) EF(+B)
  // displayType: ErrorDisplayType.toast,   // %49'1 .AJA
  onRetry: () => retry(),
);
```

---

## <× #FH'9 'D#.7'!

```dart
// #.7'! 'D4(C)
NetworkError.noInternet()
NetworkError.timeout()
NetworkError.serverUnreachable()

// #.7'! 'DE5'/B)
AuthError.invalidCredentials()
AuthError.sessionExpired()
AuthError.unauthorized()

// #.7'! 'D*-BB
ValidationError.fromMap(errors)

// #.7'! 'D.'/E
ServerError.internal()
ServerError.serviceUnavailable()

// #.7'! 'DEHB9
PermissionError.locationDenied()
GeofenceError.outsideBoundary(distance: 250, radius: 100)

// #.7'! 'D#9E'D
BusinessError.notFound(''D7D(')
BusinessError.insufficientBalance()
```

---

##  Checklist DD*C'ED

- [ ] '3*J1'/ 'DEDA'* 'DE7DH():
  ```dart
  import '../core/errors/app_error.dart';
  import '../core/errors/error_handler.dart';
  import '../core/widgets/error_widgets.dart';
  ```

- [ ] AJ Cubit: catch 'D#.7'! H*-HJDG' D@ AppError
- [ ] AJ Screen: '3*./'E BlocConsumer
- [ ] %6'A) Listener D916 'D#.7'!
- [ ] %6'A) Builder D(F'! 'DH',G)
- [ ] E9'D,) -'D'*: Loading, Error, Empty, Success
- [ ] %6'A) 21 Retry DD9EDJ'* 'DB'(D) DD%9'/)

---

## =Ö 'D/DJD 'D4'ED

1',9 `ERROR_HANDLING_GUIDE.md` DD#E+D) 'D*A5JDJ) H#A6D 'DEE'13'*.

---

## <¯ E+'D C'ED 31J9

```dart
// 1. Cubit
class ProductsCubit extends Cubit<ProductsState> {
  Future<void> loadProducts() async {
    emit(state.copyWith(isLoading: true));
    try {
      final products = await _repo.getProducts();
      emit(state.copyWith(isLoading: false, products: products));
    } on DioException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: fromDioException(e),
      ));
    }
  }
}

// 2. Screen
class ProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(''DEF*,'*')),
      body: BlocConsumer<ProductsCubit, ProductsState>(
        listener: (context, state) {
          if (state.error != null) {
            ErrorHandler.handle(
              context: context,
              error: state.error!,
              onRetry: () => context.read<ProductsCubit>().loadProducts(),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.products.isEmpty) {
            return EmptyStateWidget(
              title: 'D' *H,/ EF*,'*',
              icon: Icons.shopping_bag_outlined,
            );
          }

          return ListView.builder(
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: state.products[index]);
            },
          );
        },
      ),
    );
  }
}
```

'D"F #5(- D/JC F8'E E9'D,) #.7'! '-*1'AJ! <‰
