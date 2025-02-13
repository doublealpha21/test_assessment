import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:test_assessment/models/task.dart';

class TaskFilter {
  final bool? isCompleted;
  final PriorityLevel? priority;

  TaskFilter({this.isCompleted, this.priority});
}

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter());

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskProvider);
  final filter = ref.watch(taskFilterProvider);

  return tasks.where((task) {
    if (filter.isCompleted != null && task.isCompleted != filter.isCompleted) {
      return false;
    }
    if (filter.priority != null && task.priority != filter.priority) {
      return false;
    }
    return true;
  }).toList();
});

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('tasks') ?? [];
    state = tasksJson
        .map((task) => Task.fromJson(jsonDecode(task)))
        .toList();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = state
        .map((task) => jsonEncode(task.toJson()))
        .toList();
    await prefs.setStringList('tasks', tasksJson);
  }

  Future<void> addTask(Task task) async {
    state = [...state, task];
    await _saveTasks();
  }

  Future<void> updateTask(int index, Task task) async {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) task else state[i]
    ];
    await _saveTasks();
  }

  Future<void> deleteTask(int index) async {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i]
    ];
    await _saveTasks();
  }

  Future<void> toggleTaskCompletion(int index) async {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          state[i].copyWith(isCompleted: !state[i].isCompleted)
        else
          state[i]
    ];
    await _saveTasks();
  }
}