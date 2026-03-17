// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Kipera';

  @override
  String get onboardingTitle1 => 'Ahorra Inteligente';

  @override
  String get onboardingDesc1 =>
      'Elige entre 8 métodos de ahorro que se adaptan a tu estilo de vida';

  @override
  String get onboardingTitle2 => 'Sigue Tu Progreso';

  @override
  String get onboardingDesc2 =>
      'Visualiza tus ahorros con heatmaps y estadísticas';

  @override
  String get onboardingTitle3 => 'Alcanza Tus Metas';

  @override
  String get onboardingDesc3 =>
      'Desbloquea logros y mantente motivado con rachas diarias';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get next => 'Siguiente';

  @override
  String get skip => 'Omitir';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get displayName => 'Nombre';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get resetPassword => 'Restablecer Contraseña';

  @override
  String get dontHaveAccount => '¿No tienes cuenta? Regístrate';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta? Inicia Sesión';

  @override
  String get sendResetLink => 'Enviar enlace';

  @override
  String get orContinueWith => 'O continuar con';

  @override
  String get google => 'Google';

  @override
  String get home => 'Inicio';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get calendar => 'Calendario';

  @override
  String get settings => 'Ajustes';

  @override
  String get createGoal => 'Crear Meta';

  @override
  String get goalName => 'Nombre de la Meta';

  @override
  String get targetAmount => 'Monto Objetivo';

  @override
  String get selectMethod => 'Seleccionar Método';

  @override
  String get preview => 'Vista Previa';

  @override
  String get selectColor => 'Seleccionar Color';

  @override
  String get selectIcon => 'Seleccionar Ícono';

  @override
  String get confirm => 'Confirmar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Reanudar';

  @override
  String get abandon => 'Abandonar';

  @override
  String get todaysSaving => 'Ahorro de Hoy';

  @override
  String get checkIn => 'Registrar';

  @override
  String get markAsSaved => 'Marcar como Ahorrado';

  @override
  String get streak => 'Racha';

  @override
  String get days => 'días';

  @override
  String get totalSaved => 'Total Ahorrado';

  @override
  String get remaining => 'Restante';

  @override
  String get progress => 'Progreso';

  @override
  String get daysLeft => 'Días Restantes';

  @override
  String get achievements => 'Logros';

  @override
  String get unlocked => 'Desbloqueado';

  @override
  String get locked => 'Bloqueado';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get lightMode => 'Modo Claro';

  @override
  String get language => 'Idioma';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get reminderTime => 'Hora del Recordatorio';

  @override
  String get premium => 'Premium';

  @override
  String get upgradeToPremium => 'Actualizar a Premium';

  @override
  String get monthlyPlan => 'Plan Mensual';

  @override
  String get yearlyPlan => 'Plan Anual';

  @override
  String get perMonth => '/mes';

  @override
  String get perYear => '/año';

  @override
  String get progressive => 'Progresivo';

  @override
  String get progressiveDesc =>
      'Empieza pequeño, aumenta diario. Día 1=\$1, Día 2=\$2...';

  @override
  String get fixedDaily => 'Fijo Diario';

  @override
  String get fixedDailyDesc => 'El mismo monto cada día. Simple y consistente.';

  @override
  String get reverseProgressive => 'Progresivo Inverso';

  @override
  String get reverseProgressiveDesc =>
      'Empieza alto, disminuye diario. Alta motivación al inicio.';

  @override
  String get weeklyChallenge => 'Desafío Semanal';

  @override
  String get weeklyChallengeDesc => 'Aumenta tu ahorro cada semana.';

  @override
  String get randomEnvelopes => 'Aleatorio (Sobres)';

  @override
  String get randomEnvelopesDesc =>
      'Montos aleatorios cada día. ¡Divertido y sorprendente!';

  @override
  String get multiplier => 'Multiplicador';

  @override
  String get multiplierDesc => 'Crecimiento exponencial con tope diario.';

  @override
  String get biWeeklySteps => 'Escalonado Bi-Semanal';

  @override
  String get biWeeklyStepsDesc => 'Aumenta el monto cada dos semanas.';

  @override
  String get penaltyMethod => 'Penalización';

  @override
  String get penaltyMethodDesc =>
      'Ahorra un monto fijo cada vez que haces un mal hábito.';

  @override
  String get freeMethods => 'Gratis';

  @override
  String get premiumMethods => 'Premium';

  @override
  String estimatedDays(int days) {
    return 'Estimado: $days días';
  }

  @override
  String estimatedTotal(String amount) {
    return 'Total: \$$amount';
  }

  @override
  String get today => 'Hoy';

  @override
  String get thisWeek => 'Esta Semana';

  @override
  String get thisMonth => 'Este Mes';

  @override
  String get allTime => 'Todo';

  @override
  String get noGoalsYet => 'Sin metas aún';

  @override
  String get createYourFirstGoal => '¡Crea tu primera meta de ahorro!';

  @override
  String get congratulations => '¡Felicidades!';

  @override
  String get achievementUnlocked => '¡Logro Desbloqueado!';

  @override
  String get goalCompleted => '¡Meta Cumplida!';

  @override
  String get firstStep => 'Primer Paso';

  @override
  String get firstStepDesc => 'Completa tu primer ahorro';

  @override
  String get streak3 => 'Racha de 3';

  @override
  String get streak3Desc => 'Ahorra 3 días seguidos';

  @override
  String get weeklyWarrior => 'Guerrero Semanal';

  @override
  String get weeklyWarriorDesc => 'Ahorra 7 días seguidos';

  @override
  String get biweeklyChampion => 'Campeón Quincenal';

  @override
  String get biweeklyChampionDesc => 'Ahorra 14 días seguidos';

  @override
  String get monthlyMaster => 'Maestro Mensual';

  @override
  String get monthlyMasterDesc => 'Ahorra 30 días seguidos';

  @override
  String get centurion => 'Centurión';

  @override
  String get centurionDesc => 'Ahorra 100 días seguidos';

  @override
  String get quarterWay => '25% del Camino';

  @override
  String get quarterWayDesc => 'Alcanza el 25% de tu meta';

  @override
  String get halfWay => '¡Mitad del Camino!';

  @override
  String get halfWayDesc => 'Alcanza el 50% de tu meta';

  @override
  String get almostThere => '¡Casi Ahí!';

  @override
  String get almostThereDesc => 'Alcanza el 75% de tu meta';

  @override
  String get goalAchieved => '¡Meta Lograda!';

  @override
  String get goalAchievedDesc => 'Completa el 100% de tu meta';

  @override
  String get club100 => 'Club de los \$100';

  @override
  String get club100Desc => 'Ahorra \$100 en total';

  @override
  String get club1000 => 'Club de los \$1,000';

  @override
  String get club1000Desc => 'Ahorra \$1,000 en total';

  @override
  String get perfectWeek => 'Semana Perfecta';

  @override
  String get perfectWeekDesc => 'Ahorra cada día de una semana completa';

  @override
  String get perfectMonth => 'Mes Perfecto';

  @override
  String get perfectMonthDesc => 'Ahorra cada día de un mes completo';

  @override
  String get comeback => 'Regreso Triunfal';

  @override
  String get comebackDesc => 'Retoma el ahorro después de 3+ días sin ahorrar';

  @override
  String get profile => 'Perfil';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get version => 'Versión';

  @override
  String get aboutKipera => 'Acerca de Kipera';
}
