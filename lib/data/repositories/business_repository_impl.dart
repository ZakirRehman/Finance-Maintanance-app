import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fpdart/fpdart.dart';
import '../models/business_models.dart';

class BusinessRepository {
  final SupabaseClient _supabase;

  BusinessRepository(this._supabase);

  // --- Finances ---
  Future<Either<String, List<FinanceModel>>> getFinances() async {
    try {
      final response = await _supabase.from('finances').select().order('date', ascending: false);
      return Right((response as List).map((e) => FinanceModel.fromJson(e)).toList());
    } catch (e) { return Left(e.toString()); }
  }

  Future<Either<String, FinanceModel>> addFinance(FinanceModel model) async {
    try {
      final data = model.toJson();
      data['user_id'] = _supabase.auth.currentUser!.id;
      final response = await _supabase.from('finances').insert(data).select().single();
      return Right(FinanceModel.fromJson(response));
    } catch (e) { return Left(e.toString()); }
  }

  // --- Tasks ---
  Future<Either<String, List<TaskModel>>> getTasks() async {
    try {
      final response = await _supabase.from('tasks').select().order('created_at', ascending: false);
      return Right((response as List).map((e) => TaskModel.fromJson(e)).toList());
    } catch (e) { return Left(e.toString()); }
  }

  Future<Either<String, TaskModel>> addTask(TaskModel model) async {
    try {
      final data = model.toJson();
      data['user_id'] = _supabase.auth.currentUser!.id;
      final response = await _supabase.from('tasks').insert(data).select().single();
      return Right(TaskModel.fromJson(response));
    } catch (e) { return Left(e.toString()); }
  }

  Future<Either<String, TaskModel>> updateTask(TaskModel model) async {
    try {
      final response = await _supabase.from('tasks').update(model.toJson()).eq('id', model.id).select().single();
      return Right(TaskModel.fromJson(response));
    } catch (e) { return Left(e.toString()); }
  }

  // --- Notes ---
  Future<Either<String, List<NoteModel>>> getNotes() async {
    try {
      final response = await _supabase.from('notes').select().order('created_at', ascending: false);
      return Right((response as List).map((e) => NoteModel.fromJson(e)).toList());
    } catch (e) { return Left(e.toString()); }
  }

  Future<Either<String, NoteModel>> addNote(NoteModel model) async {
    try {
      final data = model.toJson();
      data['user_id'] = _supabase.auth.currentUser!.id;
      final response = await _supabase.from('notes').insert(data).select().single();
      return Right(NoteModel.fromJson(response));
    } catch (e) { return Left(e.toString()); }
  }

  // --- Goals ---
  Future<Either<String, List<GoalModel>>> getGoals() async {
    try {
      final response = await _supabase.from('goals').select().order('is_reached', ascending: true);
      return Right((response as List).map((e) => GoalModel.fromJson(e)).toList());
    } catch (e) { return Left(e.toString()); }
  }

  Future<Either<String, GoalModel>> addGoal(GoalModel model) async {
    try {
      final data = model.toJson();
      data['user_id'] = _supabase.auth.currentUser!.id;
      final response = await _supabase.from('goals').insert(data).select().single();
      return Right(GoalModel.fromJson(response));
    } catch (e) { return Left(e.toString()); }
  }

  Future<Either<String, GoalModel>> updateGoal(GoalModel model) async {
    try {
      final response = await _supabase.from('goals').update(model.toJson()).eq('id', model.id).select().single();
      return Right(GoalModel.fromJson(response));
    } catch (e) { return Left(e.toString()); }
  }

  Future<Either<String, NoteModel>> updateNote(NoteModel model) async {
    try {
      final response = await _supabase.from('notes').update(model.toJson()).eq('id', model.id).select().single();
      return Right(NoteModel.fromJson(response));
    } catch (e) { return Left(e.toString()); }
  }

  // Generic Delete
  Future<Either<String, void>> deleteItem(String table, String id) async {
    try {
      await _supabase.from(table).delete().eq('id', id);
      return const Right(null);
    } catch (e) { return Left(e.toString()); }
  }
}
