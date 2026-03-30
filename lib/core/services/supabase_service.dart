import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized service for all Supabase database operations.
/// Encapsulates CRUD for profiles, goals, entries, members, and invitations.
class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);
  
  SupabaseClient get client => _client;

  // ---------------------------------------------------------------------------
  // Profiles
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response =
          await _client.from('profiles').select().eq('id', userId).maybeSingle();
      return response;
    } catch (e) {
      debugPrint('❌ [SupabaseService] getProfile error: $e');
      return null;
    }
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _client.from('profiles').update(data).eq('id', userId);
    } catch (e) {
      debugPrint('❌ [SupabaseService] updateProfile error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Goals
  // ---------------------------------------------------------------------------

  Future<void> upsertGoal(Map<String, dynamic> goalData) async {
    try {
      await _client.from('savings_goals').upsert(goalData);
    } catch (e) {
      debugPrint('❌ [SupabaseService] upsertGoal error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchGoals(String userId) async {
    try {
      final response = await _client
          .from('savings_goals')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ [SupabaseService] fetchGoals error: $e');
      return [];
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      await _client.from('savings_goals').delete().eq('id', goalId);
    } catch (e) {
      debugPrint('❌ [SupabaseService] deleteGoal error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Entries
  // ---------------------------------------------------------------------------

  Future<void> upsertEntry(Map<String, dynamic> entryData) async {
    try {
      await _client.from('saving_entries').upsert(entryData);
    } catch (e) {
      debugPrint('❌ [SupabaseService] upsertEntry error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchEntriesForGoal(String goalId) async {
    try {
      final response = await _client
          .from('saving_entries')
          .select()
          .eq('goal_id', goalId)
          .order('date', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ [SupabaseService] fetchEntriesForGoal error: $e');
      return [];
    }
  }

  /// Fetch entries updated after [since] for all goals the user can access.
  Future<List<Map<String, dynamic>>> fetchEntriesSince(DateTime since) async {
    try {
      final response = await _client
          .from('saving_entries')
          .select()
          .gte('created_at', since.toIso8601String())
          .order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ [SupabaseService] fetchEntriesSince error: $e');
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Members
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> fetchGoalMembers(String goalId) async {
    try {
      final response = await _client
          .from('goal_members')
          .select('*, profiles(display_name, avatar_url, email)')
          .eq('goal_id', goalId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ [SupabaseService] fetchGoalMembers error: $e');
      return [];
    }
  }

  Future<void> insertMember(Map<String, dynamic> data) async {
    try {
      await _client.from('goal_members').insert(data);
    } catch (e) {
      debugPrint('❌ [SupabaseService] insertMember error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Invitations
  // ---------------------------------------------------------------------------

  Future<void> createInvitation(Map<String, dynamic> data) async {
    try {
      await _client.from('goal_invitations').insert(data);
    } catch (e) {
      debugPrint('❌ [SupabaseService] createInvitation error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchPendingInvitations(String email) async {
    try {
      final response = await _client
          .from('goal_invitations')
          .select('*, savings_goals(name, target_amount, method, method_config, icon_name, color_hex), inviter:profiles!goal_invitations_inviter_id_fkey(display_name, avatar_url)')
          .eq('invitee_email', email)
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ [SupabaseService] fetchPendingInvitations error: $e');
      return [];
    }
  }

  Future<void> acceptInvitation(String invitationId) async {
    try {
      await _client.rpc('accept_invitation', params: {
        'invitation_id': invitationId,
      });
    } catch (e) {
      debugPrint('❌ [SupabaseService] acceptInvitation error: $e');
      rethrow;
    }
  }

  Future<void> rejectInvitation(String invitationId) async {
    try {
      await _client
          .from('goal_invitations')
          .update({
            'status': 'rejected',
            'responded_at': DateTime.now().toIso8601String(),
          })
          .eq('id', invitationId);
    } catch (e) {
      debugPrint('❌ [SupabaseService] rejectInvitation error: $e');
      rethrow;
    }
  }

  Future<void> leaveCoupleGoal(String goalId, String userId, String email) async {
    try {
      // 1. Remove the user from the shared goal
      await _client
          .from('goal_members')
          .delete()
          .match({'goal_id': goalId, 'user_id': userId});

      // 2. Delete any old accepted invitations so the owner can invite them again
      await _client
          .from('goal_invitations')
          .delete()
          .match({'goal_id': goalId, 'invitee_email': email});
          
      debugPrint('✅ [SupabaseService] Successfully left couple goal: $goalId for user: $email');
    } catch (e) {
      debugPrint('❌ [SupabaseService] leaveCoupleGoal error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Sync helpers
  // ---------------------------------------------------------------------------

  /// Fetch goals updated after [since] for the current user.
  Future<List<Map<String, dynamic>>> fetchGoalsSince(DateTime since) async {
    try {
      final response = await _client
          .from('savings_goals')
          .select()
          .gte('updated_at', since.toIso8601String())
          .order('updated_at', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ [SupabaseService] fetchGoalsSince error: $e');
      return [];
    }
  }
}
