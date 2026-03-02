// Profile feature - barrel file
// 
// Este archivo exporta todos los componentes públicos de la feature profile.
// Los archivos individuales están en:
// - presentation/cubit/ - Cubits y estados
// - data/services/ - Servicios de datos
// - presentation/ - Screens y widgets
//
// NOTA: Los archivos principales (profile_cubit.dart, profile_state.dart, profile_service.dart)
// todavía están en la raíz del feature por compatibilidad.
// Gradually migrando a la estructura correcta.

// Export presentation/cubit
export 'presentation/cubit/profile_cubit.dart';
export 'presentation/cubit/profile_state.dart';

// Export data/services  
export 'data/services/profile_service.dart';
