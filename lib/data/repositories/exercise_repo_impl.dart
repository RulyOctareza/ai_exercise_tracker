import 'package:ai_exercise_tracker/core/constants/firebase_constant.dart';
import 'package:ai_exercise_tracker/core/utils/app_utils.dart';
import 'package:ai_exercise_tracker/services/firebase_firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/exercise.dart';
import '../../domain/entities/exercise_history.dart' as entity;
import '../../domain/repositories/exercise_repository.dart';
import '../models/exercise_model.dart';
import '../models/exercise_history_model.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final FirebaseFirestoreService _firestoreService;
  final Uuid _uuid = Uuid();

  ExerciseRepositoryImpl({required FirebaseFirestoreService firestoreService})
    : _firestoreService = firestoreService;

  @override
  Future<List<Exercise>> getExercises() async {
    try {
      // For initial app, we'll define exercises in code rather than in Firestore
      // In a real app, these might come from a backend
      return [
        ExerciseModel(
          id: 'pushups',
          title: 'Push Ups',
          imageAsset: 'assets/icons/pushup.gif',
          type: ExerciseType.pushUps,
          description:
              'Classic push-up exercise that targets chest, shoulders, and triceps.',
          targetRepetitions: 10,
        ),
        ExerciseModel(
          id: 'squats',
          title: 'Squats',
          imageAsset: 'assets/icons/squat.gif',
          type: ExerciseType.squats,
          description:
              'Lower body exercise that works the quads, hamstrings, and glutes.',
          targetRepetitions: 15,
        ),
        ExerciseModel(
          id: 'plank',
          title: 'Plank to Downward Dog',
          imageAsset: 'assets/icons/plank.gif',
          type: ExerciseType.downwardDogPlank,
          description:
              'Flow between plank and downward dog to engage core and shoulders.',
          targetRepetitions: 8,
        ),
        ExerciseModel(
          id: 'jumping_jack',
          title: 'Jumping Jack',
          imageAsset: 'assets/icons/jumping.gif',
          type: ExerciseType.jumpingJack,
          description:
              'Full body exercise that increases heart rate and improves coordination.',
          targetRepetitions: 20,
        ),
        ExerciseModel(
          id: 'clap',
          title: 'Clap',
          imageAsset: 'assets/icons/clap.gif',
          type: ExerciseType.clap,
          description:
              'Simple clapping exercise to practice movement detection.',
          targetRepetitions: 15,
        ),
      ];
    } catch (e) {
      print('Error getting exercises: $e');
      return [];
    }
  }

  @override
  Future<Exercise?> getExerciseById(String exerciseId) async {
    try {
      final exercises = await getExercises();
      return exercises.firstWhere((exercise) => exercise.id == exerciseId);
    } catch (e) {
      print('Error getting exercise by ID: $e');
      return null;
    }
  }

  @override
  Future<Exercise?> getExerciseByType(ExerciseType type) async {
    try {
      final exercises = await getExercises();
      return exercises.firstWhere((exercise) => exercise.type == type);
    } catch (e) {
      print('Error getting exercise by type: $e');
      return null;
    }
  }

  @override
  Future<void> saveExerciseHistory(entity.ExerciseHistory history) async {
    try {
      final historyModel = ExerciseHistoryModel.fromEntity(history);
      final historyId = history.id.isEmpty ? _uuid.v4() : history.id;

      await _firestoreService.setDocument(
        FirebaseConstants.exerciseHistoryCollection,
        historyId,
        {...historyModel.toJson(), 'id': historyId},
      );
    } catch (e) {
      throw Exception('Failed to save exercise history: ${e.toString()}');
    }
  }

  @override
  Future<List<entity.ExerciseHistory>> getExerciseHistoryForUser(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    ExerciseType? exerciseType,
  }) async {
    try {
      Query query = _firestoreService
          .collection(FirebaseConstants.exerciseHistoryCollection)
          .where('userId', isEqualTo: userId);

      if (startDate != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: startDate.toIso8601String(),
        );
      }

      if (endDate != null) {
        query = query.where(
          'date',
          isLessThanOrEqualTo: endDate.toIso8601String(),
        );
      }

      if (exerciseType != null) {
        query = query.where(
          'exerciseType',
          isEqualTo: exerciseType.toString().split('.').last,
        );
      }

      query = query.orderBy('date', descending: true);

      final snapshot = await query.get();
      final histories =
          snapshot.docs.map((doc) {
            return ExerciseHistoryModel.fromJson(
              doc.data() as Map<String, dynamic>,
            );
          }).toList();

      return histories;
    } catch (e) {
      print('Error getting exercise history: $e');
      return [];
    }
  }

  @override
  Future<entity.ExerciseHistory?> getLastExerciseRecord(
    String userId,
    ExerciseType exerciseType,
  ) async {
    try {
      final snapshot =
          await _firestoreService
              .collection(FirebaseConstants.exerciseHistoryCollection)
              .where('userId', isEqualTo: userId)
              .where(
                'exerciseType',
                isEqualTo: exerciseType.toString().split('.').last,
              )
              .orderBy('date', descending: true)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return ExerciseHistoryModel.fromJson(
        snapshot.docs.first.data() as Map<String, dynamic>,
      );
    } catch (e) {
      print('Error getting last exercise record: $e');
      return null;
    }
  }

  @override
  Future<entity.ExerciseHistory?> getBestExerciseRecord(
    String userId,
    ExerciseType exerciseType,
  ) async {
    try {
      final snapshot =
          await _firestoreService
              .collection(FirebaseConstants.exerciseHistoryCollection)
              .where('userId', isEqualTo: userId)
              .where(
                'exerciseType',
                isEqualTo: exerciseType.toString().split('.').last,
              )
              .orderBy('repetitions', descending: true)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return ExerciseHistoryModel.fromJson(
        snapshot.docs.first.data() as Map<String, dynamic>,
      );
    } catch (e) {
      print('Error getting best exercise record: $e');
      return null;
    }
  }

  @override
  Future<Map<ExerciseType, int>> getTotalRepetitionsPerType(
    String userId,
  ) async {
    try {
      final snapshot =
          await _firestoreService
              .collection(FirebaseConstants.exerciseHistoryCollection)
              .where('userId', isEqualTo: userId)
              .get();

      final Map<ExerciseType, int> totals = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final type = ExerciseHistoryModel.typeFromString(data['exerciseType']);
        final reps = data['repetitions'] as int;

        totals[type] = (totals[type] ?? 0) + reps;
      }

      return totals;
    } catch (e) {
      print('Error getting total repetitions: $e');
      return {};
    }
  }

  @override
  Future<Map<DateTime, List<entity.ExerciseHistory>>> getExerciseHistoryByDate(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final histories = await getExerciseHistoryForUser(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      // Group by date (without time)
      final Map<DateTime, List<entity.ExerciseHistory>> result = {};

      for (var history in histories) {
        final date = AppDateUtils.startOfDay(history.date);
        if (!result.containsKey(date)) {
          result[date] = [];
        }
        result[date]!.add(history);
      }

      return result;
    } catch (e) {
      print('Error getting exercise history by date: $e');
      return {};
    }
  }
}
