// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get abandon => 'Abandonar';

  @override
  String get aboutKipera => 'Acerca de Kipera';

  @override
  String get accept => 'Aceptar';

  @override
  String get accountSettings => 'Ajustes de la cuenta';

  @override
  String get achievementUnlocked => '¡Logro Desbloqueado!';

  @override
  String get achievements => 'Logros';

  @override
  String get activeGoalsLabel => 'Metas Activas';

  @override
  String get activityLabel => 'Actividad';

  @override
  String get alerts => 'Alertas';

  @override
  String get allTime => 'Todo';

  @override
  String get almostThere => '¡Casi Ahí!';

  @override
  String get almostThereDesc => 'Alcanza el 75% de tu meta';

  @override
  String get alreadyCheckedIn => '¡Ya ahorraste hoy! Vuelve mañana.';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta? Inicia Sesión';

  @override
  String get alreadyHaveAccountStart => '¿Ya tienes cuenta? ';

  @override
  String get appName => 'Kipera';

  @override
  String get biWeeklySteps => 'Escalonado Bi-Semanal';

  @override
  String get biWeeklyStepsDesc => 'Aumenta el monto cada dos semanas.';

  @override
  String get biweeklyChampion => 'Campeón Quincenal';

  @override
  String get biweeklyChampionDesc => 'Ahorra 14 días seguidos';

  @override
  String get byGoal => 'Por Meta';

  @override
  String get calendar => 'Calendario';

  @override
  String get cancel => 'Cancelar';

  @override
  String get centurion => 'Centurión';

  @override
  String get centurionDesc => 'Ahorra 100 días seguidos';

  @override
  String get checkIn => 'Registrar';

  @override
  String get checkInGoalNotFound =>
      'Meta no encontrada. Puede haber sido eliminada.';

  @override
  String get chooseReminderTime => 'Elige una hora de recordatorio diario.';

  @override
  String get club100 => 'Club de los \$100';

  @override
  String get club1000 => 'Club de los \$1,000';

  @override
  String get club1000Desc => 'Ahorra \$1,000 en total';

  @override
  String get club100Desc => 'Ahorra \$100 en total';

  @override
  String get comeback => 'Regreso Triunfal';

  @override
  String get comebackDesc => 'Retoma el ahorro después de 3+ días sin ahorrar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get congratulations => '¡Felicidades!';

  @override
  String get coupleGoalLabel => 'Meta en Pareja';

  @override
  String coupleGoalWithPartner(String name) {
    return 'con $name';
  }

  @override
  String get createAccount => 'Crear Cuenta';

  @override
  String get createGoal => 'Crear Meta';

  @override
  String get createGoalAmountValidation =>
      'Establece un monto objetivo mayor a \$0.';

  @override
  String get createGoalError =>
      'Algo salió mal al crear tu meta. Inténtalo de nuevo.';

  @override
  String get createGoalLoginRequired =>
      'Necesitas iniciar sesión para crear una meta.';

  @override
  String get createGoalNameValidation =>
      'Ponle un nombre a tu meta para identificarla fácilmente.';

  @override
  String get createGoalPartnerEmailValidation =>
      'Introduce un correo válido para tu pareja.';

  @override
  String get createGoalTimeValidation =>
      'Elige una hora de recordatorio diaria.';

  @override
  String get createGoalValidation =>
      'Por favor introduce un nombre y monto objetivo para continuar.';

  @override
  String get createYourFirstGoal => '¡Crea tu primera meta de ahorro!';

  @override
  String currentlyAt(String time) {
    return 'Actualmente a las $time';
  }

  @override
  String dailyReminderAt(String time) {
    return 'Recordatorio diario a las $time';
  }

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String dayLabel(int number) {
    return 'Día $number';
  }

  @override
  String get dayLeftToGoal => 'día restante para tu meta';

  @override
  String dayOfTotal(int completed, int total) {
    return 'Día $completed de $total';
  }

  @override
  String get days => 'días';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get decline => 'Rechazar';

  @override
  String get defaultUserName => 'Ahorrador';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String deleteGoalConfirmation(String name) {
    return '¿Estás seguro de que quieres eliminar \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String get deleteGoalTitle => 'Eliminar Meta';

  @override
  String get displayName => 'Nombre';

  @override
  String get dontHaveAccount => '¿No tienes cuenta? Regístrate';

  @override
  String get dontHaveAccountStart => '¿No tienes cuenta? ';

  @override
  String get edit => 'Editar';

  @override
  String get editGoalName => 'Editar Nombre de Meta';

  @override
  String get editReminderTime => 'Editar Hora de Recordatorio';

  @override
  String get email => 'Correo electrónico';

  @override
  String get enterEmail => 'Introduce tu correo';

  @override
  String get enterName => 'Introduce tu nombre';

  @override
  String get enterNameAndAmount =>
      'Por favor introduce un nombre y cantidad para continuar.';

  @override
  String get enterPartnerEmail => 'Introduce un correo válido para tu pareja.';

  @override
  String get cannotInviteSelf => 'No puedes invitarte a ti mismo a una meta.';

  @override
  String get enterPassword => 'Introduce tu contraseña';

  @override
  String get errorCreatingGoal =>
      'Algo salió mal al crear tu meta. Inténtalo de nuevo.';

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String estimatedDays(int days) {
    return 'Estimado: $days días';
  }

  @override
  String estimatedTotal(String amount) {
    return 'Total: \$$amount';
  }

  @override
  String get expectedLabel => 'Esperado: ';

  @override
  String get fillInformation => 'Completa tu información abajo';

  @override
  String get firstStep => 'Primer Paso';

  @override
  String get firstStepDesc => 'Completa tu primer ahorro';

  @override
  String get fixedDaily => 'Fijo Diario';

  @override
  String get fixedDailyDesc => 'El mismo monto cada día. Simple y consistente.';

  @override
  String get fixedMethodOnboardingDesc =>
      'Ahorra la misma cantidad cada día. Simple y consistente.';

  @override
  String get fixedMethodTitle => 'Fijo Diario';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get forgotPasswordDesc =>
      'Introduce tu correo para recibir un enlace de recuperación.';

  @override
  String get freeMethods => 'Gratis';

  @override
  String get freePlanStatus => 'Estás en el Plan Gratis';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get giveGoalName =>
      'Ponle un nombre a tu meta para identificarla fácilmente.';

  @override
  String get goalAchieved => '¡Meta Lograda!';

  @override
  String get goalAchievedDesc => 'Completa el 100% de tu meta';

  @override
  String get goalAchievedSubtitle => 'Completa el 100% de una meta';

  @override
  String get goalAchievedTitle => '¡Meta Alcanzada!';

  @override
  String get goalCompleted => '¡Meta Cumplida!';

  @override
  String goalCreated(String name) {
    return '¡\"$name\" creada! Tu viaje de ahorro comienza ahora.';
  }

  @override
  String goalDeletedSuccess(String name) {
    return '\"$name\" ha sido eliminada.';
  }

  @override
  String goalLabelPrefix(String name) {
    return 'Meta: $name';
  }

  @override
  String get goalName => 'Nombre de la Meta';

  @override
  String get goalNameExample => 'ej. Viaje a Europa';

  @override
  String get goalNameHint => 'Nombre de la meta';

  @override
  String get goalNotFound => 'Meta no encontrada';

  @override
  String get goalReachedLabel => '¡Meta alcanzada! ';

  @override
  String goalRenamed(String name) {
    return 'Meta renombrada a \"$name\"';
  }

  @override
  String get goalsProgress => 'Progreso de Metas';

  @override
  String get google => 'Google';

  @override
  String get halfWay => '¡Mitad del Camino!';

  @override
  String get halfWayDesc => 'Alcanza el 50% de tu meta';

  @override
  String helloUser(String name) {
    return '¡Hola, $name!';
  }

  @override
  String get home => 'Inicio';

  @override
  String get invalidEmail => 'Introduce un correo válido';

  @override
  String get invalidEmailError => 'Por favor introduce un correo válido.';

  @override
  String get invitationAcceptedError =>
      'No se pudo aceptar la invitación. Inténtalo de nuevo.';

  @override
  String get invitationAcceptedSuccess =>
      '❤️ ¡Invitación aceptada! Ya pueden ahorrar juntos.';

  @override
  String get invitationDeclinedError =>
      'No se pudo rechazar la invitación. Inténtalo de nuevo.';

  @override
  String get invitationDeclinedSuccess => 'Invitación rechazada.';

  @override
  String get invitationEmptyState =>
      'Cuando alguien te invite a ahorrar en pareja, aparecerá aquí.';

  @override
  String get invitationError =>
      'No se pudo enviar la invitación. Inténtalo de nuevo.';

  @override
  String invitationSent(String email) {
    return '❤️ ¡Invitación enviada a $email!';
  }

  @override
  String get invitationSentError =>
      'No se pudo enviar la invitación. Inténtalo de nuevo.';

  @override
  String invitationSentSuccess(String email) {
    return '❤️ ¡Invitación enviada a $email!';
  }

  @override
  String get inviteAnotherPartner => 'Invitar a Otra Pareja';

  @override
  String get invitePartner => 'Invitar Pareja';

  @override
  String get language => 'Idioma';

  @override
  String get leaveGoal => 'Salir de Meta';

  @override
  String leaveGoalConfirmation(String name) {
    return '¿Estás seguro de que quieres salir de \"$name\"? Serás eliminado de esta meta de pareja y dejarás de recibir recordatorios.';
  }

  @override
  String get leaveSharedGoalSubtitle =>
      'Dejar de sincronizar y cancelar recordatorios';

  @override
  String get leaveSharedGoalTitle => 'Salir de Meta Compartida';

  @override
  String get leftGoalError => 'Error al salir de la meta.';

  @override
  String leftGoalSuccess(String name) {
    return 'Has salido de \"$name\".';
  }

  @override
  String get lightMode => 'Modo Claro';

  @override
  String get loadInvitationsError => 'No se pudieron cargar las invitaciones';

  @override
  String get locked => 'Bloqueado';

  @override
  String get loggingOut => 'Cerrando sesión...';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get loginLink => 'Inicia Sesión';

  @override
  String get loginRequired => 'Necesitas iniciar sesión para crear una meta.';

  @override
  String get loginToAccount => 'Inicia sesión en tu cuenta';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get markAsSaved => 'Marcar como Ahorrado';

  @override
  String get maybeLater => 'Quizás después';

  @override
  String get monthlyMaster => 'Maestro Mensual';

  @override
  String get monthlyMasterDesc => 'Ahorra 30 días seguidos';

  @override
  String get monthlyPlan => 'Plan Mensual';

  @override
  String get multiplier => 'Multiplicador';

  @override
  String get multiplierDesc => 'Crecimiento exponencial con tope diario.';

  @override
  String get multiplierMethodOnboardingDesc =>
      'Crecimiento exponencial con un tope diario para grandes resultados.';

  @override
  String get multiplierMethodTitle => 'Multiplicador';

  @override
  String get next => 'Siguiente';

  @override
  String get noGoalsYet => 'Sin metas aún';

  @override
  String get noPendingInvitations => 'No hay invitaciones pendientes';

  @override
  String get notSet => 'No establecido';

  @override
  String notificationBody(String name) {
    return 'No olvides tu meta \"$name\" hoy.';
  }

  @override
  String notificationBodyJoint(String name) {
    return 'No olvides tu ahorro conjunto para \"$name\" hoy.';
  }

  @override
  String get notifications => 'Notificaciones';

  @override
  String get ofLabel => 'de ';

  @override
  String get ok => 'Aceptar';

  @override
  String get onboardingDesc1 =>
      'Elige entre 8 métodos de ahorro que se adaptan a tu estilo de vida';

  @override
  String get onboardingDesc2 =>
      'Visualiza tus ahorros con heatmaps y estadísticas';

  @override
  String get onboardingDesc3 =>
      'Desbloquea logros y mantente motivado con rachas diarias';

  @override
  String get onboardingEducation => 'Educación';

  @override
  String get onboardingEmergency => 'Fondo de Emergencia';

  @override
  String get onboardingFun => 'Diversión y Entretenimiento';

  @override
  String get onboardingGoalSubtitle =>
      'Elige en qué te gustaría enfocarte primero.';

  @override
  String get onboardingGoalTitle => '¿Para qué quieres\nahorrar?';

  @override
  String get onboardingHome => 'Hogar';

  @override
  String get onboardingMethodSubtitle =>
      'Elige un método que se adapte a tu estilo de vida.';

  @override
  String get onboardingMethodTitle => 'Ahorra con Estrategia';

  @override
  String get onboardingTech => 'Tecnología y Gadgets';

  @override
  String get onboardingTitle1 => 'Ahorra Inteligente';

  @override
  String get onboardingTitle2 => 'Sigue Tu Progreso';

  @override
  String get onboardingTitle3 => 'Alcanza Tus Metas';

  @override
  String get onboardingTrackSubtitle =>
      'Visualiza tus ahorros y desbloquea logros.';

  @override
  String get onboardingTrackTitle => 'Sigue tu\nProgreso';

  @override
  String get onboardingTravel => 'Viajes';

  @override
  String get orContinueWith => 'O continuar con';

  @override
  String get orLoginWith => 'o Inicia sesión con';

  @override
  String get orSignUpWith => 'o Regístrate con';

  @override
  String get partnerEmailHint => 'Correo de tu pareja';

  @override
  String get partnerInviteInfo =>
      'Tu pareja recibirá una invitación para unirse a esta meta.';

  @override
  String get partnerLabel => 'Pareja';

  @override
  String get password => 'Contraseña';

  @override
  String get passwordMinChar => 'Mínimo 6 caracteres';

  @override
  String get pause => 'Pausar';

  @override
  String get penaltyMethod => 'Penalización';

  @override
  String get penaltyMethodDesc =>
      'Ahorra un monto fijo cada vez que haces un mal hábito.';

  @override
  String get perMonth => '/mes';

  @override
  String get perYear => '/año';

  @override
  String get perfectMonth => 'Mes Perfecto';

  @override
  String get perfectMonthDesc => 'Ahorra cada día de un mes completo';

  @override
  String get perfectWeek => 'Semana Perfecta';

  @override
  String get perfectWeekDesc => 'Ahorra cada día de una semana completa';

  @override
  String get premium => 'Premium';

  @override
  String get premiumMethods => 'Premium';

  @override
  String get premiumPlan => 'Plan Premium';

  @override
  String get premiumSubtitle =>
      'Desbloquea desafíos exclusivos y análisis avanzados de hábitos.';

  @override
  String get premiumUpgradeDesc =>
      'Obtén acceso a los 8 métodos de ahorro, metas ilimitadas, estadísticas avanzadas, sincronización en la nube, notificaciones personalizadas y una experiencia sin anuncios.';

  @override
  String get premiumUpgradeTitle => 'Actualización Premium';

  @override
  String get preview => 'Vista Previa';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get proLabel => 'PRO';

  @override
  String get profile => 'Perfil';

  @override
  String get progress => 'Progreso';

  @override
  String get progressive => 'Progresivo';

  @override
  String get progressiveDesc =>
      'Empieza pequeño, aumenta diario. Día 1=\$1, Día 2=\$2...';

  @override
  String get progressiveMethodOnboardingDesc =>
      'Empieza con poco y aumenta cada día. Día 1 = \$1, Día 2 = \$2...';

  @override
  String get progressiveMethodTitle => 'Progresivo';

  @override
  String get quarterWay => '25% del Camino';

  @override
  String get quarterWayDesc => 'Alcanza el 25% de tu meta';

  @override
  String get randomEnvelopes => 'Aleatorio (Sobres)';

  @override
  String get randomEnvelopesDesc =>
      'Montos aleatorios cada día. ¡Divertido y sorprendente!';

  @override
  String get randomMethodOnboardingDesc =>
      'Cantidades aleatorias cada día. ¡Divertido y sorprendente!';

  @override
  String get randomMethodTitle => 'Sobres Aleatorios';

  @override
  String get reachGoalInPrefix => '¡Puedes alcanzar tu meta en solo ';

  @override
  String get reachGoalInSuffix => '!';

  @override
  String reachGoalRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'días restantes para tu meta',
      one: 'día restante para tu meta',
    );
    return '$_temp0';
  }

  @override
  String get register => 'Registrarse';

  @override
  String get remaining => 'Restante';

  @override
  String get rememberMe => 'Recuérdame';

  @override
  String get reminderTime => 'Hora de recordatorio';

  @override
  String reminderUpdated(String time) {
    return 'Recordatorio actualizado a $time';
  }

  @override
  String get requiredReminder => 'Requerido — mantente en el camino';

  @override
  String get resetLinkSent => 'Revisa tu correo para encontrar el enlace.';

  @override
  String get resetPassword => 'Restablecer Contraseña';

  @override
  String get resume => 'Reanudar';

  @override
  String get reverseProgressive => 'Progresivo Inverso';

  @override
  String get reverseProgressiveDesc =>
      'Empieza alto, disminuye diario. Alta motivación al inicio.';

  @override
  String get save => 'Guardar';

  @override
  String savePercentage(String percentage) {
    return 'Ahorra $percentage';
  }

  @override
  String get saveWithPartner => 'Ahorra junto con tu pareja';

  @override
  String get savingHeatmap => 'Mapa de Calor de Ahorro';

  @override
  String get selectColor => 'Seleccionar Color';

  @override
  String get selectIcon => 'Seleccionar Ícono';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get selectMethod => 'Seleccionar Método';

  @override
  String get send => 'Enviar';

  @override
  String get sendInvitationNewPartner => 'Enviar invitación a una nueva pareja';

  @override
  String get sendResetLink => 'Enviar enlace';

  @override
  String get setTargetAmount =>
      'Establece una cantidad mayor a \$0 para tu meta.';

  @override
  String get settings => 'Ajustes';

  @override
  String get showInWidget => 'Mostrar en Widget';

  @override
  String get showInWidgetSubtitle => 'Mostrar este objetivo en el Home Screen';

  @override
  String get signUpLink => 'Regístrate';

  @override
  String get skip => 'Omitir';

  @override
  String get someone => 'Alguien';

  @override
  String get statistics => 'Estadísticas';

  @override
  String stepOfTotal(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get streak => 'Racha';

  @override
  String get streak3 => 'Racha de 3';

  @override
  String get streak3Desc => 'Ahorra 3 días seguidos';

  @override
  String get streak7Subtitle => 'Ahorra durante 7 días seguidos';

  @override
  String get streak7Title => 'Racha de 7 Días';

  @override
  String get subscribe => 'Suscribirse';

  @override
  String get tapToSetReminder => 'Toca para establecer un recordatorio';

  @override
  String get targetAmount => 'Monto Objetivo';

  @override
  String get targetAmountExample => '1000';

  @override
  String get thisActionCannotBeUndone => 'Esta acción no se puede deshacer';

  @override
  String get thisMonth => 'Este Mes';

  @override
  String get thisWeek => 'Esta Semana';

  @override
  String get timeToSave => '¡Hora de ahorrar!';

  @override
  String get today => 'Hoy';

  @override
  String get todayLabel => 'Hoy';

  @override
  String get todaysSaving => 'Ahorro de Hoy';

  @override
  String get totalLabel => 'Total: ';

  @override
  String get totalSaved => 'Total Ahorrado';

  @override
  String get totalTargetLabel => 'Objetivo Total';

  @override
  String get turnIntoCoupleGoal => 'Convertir en meta de pareja';

  @override
  String get unknownGoal => 'Meta desconocida';

  @override
  String get unlocked => 'Desbloqueado';

  @override
  String get upgrade => 'Actualizar';

  @override
  String get upgradeToPremium => 'Actualizar a Premium';

  @override
  String get userLabel => 'Tú';

  @override
  String get version => 'Versión';

  @override
  String get viewProfile => 'Ver perfil';

  @override
  String get weeklyChallenge => 'Desafío Semanal';

  @override
  String get weeklyChallengeDesc => 'Aumenta tu ahorro cada semana.';

  @override
  String get weeklyWarrior => 'Guerrero Semanal';

  @override
  String get weeklyWarriorDesc => 'Ahorra 7 días seguidos';

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String widgetGoalSet(String name) {
    return '📱 \"$name\" se mostrará en el widget';
  }

  @override
  String get yearlyPlan => 'Plan Anual';

  @override
  String get yesterdayLabel => 'Ayer';
}
