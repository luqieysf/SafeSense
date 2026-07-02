import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/role_selection_screen.dart';
import '../screens/child/child_login_screen.dart';
import '../screens/child/child_home_screen.dart';
import '../screens/child/child_alert_screen.dart';
import '../screens/child/child_routine_screen.dart';
import '../screens/child/child_token_screen.dart';
import '../screens/child/child_profile_view_screen.dart';
import '../screens/parent/parent_login_screen.dart';
import '../screens/parent/parent_register_screen.dart';
import '../screens/parent/parent_dashboard_screen.dart';
import '../screens/parent/parent_children_screen.dart';
import '../screens/parent/parent_add_child_screen.dart';
import '../screens/parent/parent_edit_child_screen.dart';
import '../screens/parent/parent_event_log_screen.dart';
import '../screens/parent/parent_create_task_screen.dart';
import '../screens/caregiver/caregiver_login_screen.dart';
import '../screens/caregiver/caregiver_register_screen.dart';
import '../screens/caregiver/caregiver_dashboard_screen.dart';
import '../screens/caregiver/caregiver_event_log_screen.dart';
import '../screens/caregiver/caregiver_child_view_screen.dart';
import '../screens/caregiver/caregiver_child_tasks_screen.dart';
import '../screens/shared/event_list_screen.dart';
import '../screens/shared/student_events_screen.dart';
import '../screens/shared/event_detail_screen.dart';
import '../screens/shared/report_screen.dart';
import '../screens/shared/user_profile_screen.dart';
import '../screens/child/child_audio_screen.dart';
import '../screens/shared/event_log_select_child_screen.dart';
import '../screens/shared/event_log_select_caregiver_screen.dart';
import '../screens/shared/notifications_screen.dart';
import '../screens/shared/handover_notes_screen.dart';

class AppRoutes {

  AppRoutes._();

// Shared
  static const String splash        = '/';
  static const String roleSelection = '/role-selection';
  static const String eventList     = '/shared/event-list';
  static const String studentEvents = '/shared/student-events';
  static const String eventDetail   = '/shared/event-detail';
  static const String report        = '/shared/report';
  static const String userProfile   = '/shared/user-profile';

// Child
  static const String childLogin       = '/child/login';
  static const String childHome        = '/child/home';
  static const String childAlert       = '/child/alert';
  static const String childRoutine     = '/child/routine';
  static const String childToken       = '/child/token';
  static const String childProfileView = '/child/profile';
  static const String childAudio       = '/child/audio';

// Parent
  static const String parentLogin    = '/parent/login';
  static const String parentRegister = '/parent/register';
  static const String parentDashboard    = '/parent/dashboard';
  static const String parentChildren     = '/parent/children';
  static const String parentAddChild     = '/parent/add-child';
  static const String parentEditChild    = '/parent/edit-child';
  static const String parentEventLog     = '/parent/event-log';
  static const String parentEventSelectChild = '/parent/event-select-child';
  static const String parentCreateTask   = '/parent/create-task';

// Caregiver
  static const String caregiverLogin      = '/caregiver/login';
  static const String caregiverRegister   = '/caregiver/register';
  static const String caregiverDashboard  = '/caregiver/dashboard';
  static const String caregiverEventLog   = '/caregiver/event-log';
  static const String caregiverChildView  = '/caregiver/child-view';
  static const String caregiverChildTasks = '/caregiver/child-tasks';
  static const String caregiverEventSelectStudent = '/caregiver/event-select-student';

  static const String notifications   = '/shared/notifications';
  static const String handoverNotes   = '/shared/handover-notes';

  static Map<String, WidgetBuilder> get routes => {
    splash:              (context) => const SplashScreen(),
    roleSelection:       (context) => const RoleSelectionScreen(),

    // shared
    eventList:           (context) => const EventListScreen(),
    studentEvents:       (context) => const StudentEventsScreen(),
    eventDetail:         (context) => const EventDetailScreen(),
    report:              (context) => const ReportScreen(),
    userProfile:         (context) => const UserProfileScreen(),

    // child
    childLogin:          (context) => const ChildLoginScreen(),
    childHome:           (context) => const ChildHomeScreen(),
    childAlert:          (context) => const ChildAlertScreen(),
    childRoutine:        (context) => const ChildRoutineScreen(),
    childToken:          (context) => const ChildTokenScreen(),
    childProfileView:    (context) => const ChildProfileViewScreen(),

    // parent
    parentLogin:         (context) => const ParentLoginScreen(),
    parentRegister:      (context) => const ParentRegisterScreen(),
    parentDashboard:     (context) => const ParentDashboardScreen(),
    parentChildren:      (context) => const ParentChildrenScreen(),
    parentAddChild:      (context) => const ParentAddChildScreen(),
    parentEditChild:     (context) => const ParentEditChildScreen(),
    parentEventLog:      (context) => const ParentEventLogScreen(),
    parentCreateTask:    (context) => const ParentCreateTaskScreen(),

    // caregiver
    caregiverLogin:      (context) => const CaregiverLoginScreen(),
    caregiverRegister:   (context) => const CaregiverRegisterScreen(),
    caregiverDashboard:  (context) => const CaregiverDashboardScreen(),
    caregiverEventLog:   (context) => const CaregiverEventLogScreen(),
    caregiverChildView:  (context) => const CaregiverChildViewScreen(),
    caregiverChildTasks: (context) => const CaregiverChildTasksScreen(),

    // audio + event log selection
    childAudio:                    (context) => const ChildAudioScreen(),
    parentEventSelectChild:        (context) => const EventLogSelectChildScreen(),
    caregiverEventSelectStudent:   (context) => const EventLogSelectCaregiverScreen(),

    notifications:  (context) => const NotificationsScreen(),
    handoverNotes:  (context) => const HandoverNotesScreen(),

  };
}
