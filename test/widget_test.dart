import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primera_app/main.dart';

void main() {
  testWidgets('Verifica que la app carga correctamente la pantalla de inicio', (WidgetTester tester) async {
    // Construye la aplicación
    await tester.pumpWidget(const MiPrimeraApp());

    // Verifica que se renderiza el título del encabezado
    expect(find.text('MI PRIMERA APLICACIÓN'), findsOneWidget);
    expect(find.text('COMPUTER'), findsOneWidget);
  });
}
