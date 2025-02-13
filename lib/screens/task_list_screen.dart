import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];
  TaskFilter filter = TaskFilter(isCompleted: null, priority: null);

  @override
  Widget build(BuildContext context) {
    // Apply filters
    final filteredTasks = tasks.where((task) {
      if (filter.isCompleted != null &&
          task.isCompleted != filter.isCompleted) {
        return false;
      }
      if (filter.priority != null && task.priority != filter.priority) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Text(task.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    setState(() {
                      final taskIndex = tasks.indexOf(task);
                      tasks[taskIndex] = task.copyWith(isCompleted: value);
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showTaskDialog(context, task: task),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      tasks.remove(task);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // void _showFilterDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Filter Tasks'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           DropdownButton<bool?>(
  //             value: filter.isCompleted,
  //             items: const [
  //               DropdownMenuItem(value: null, child: Text('All')),
  //               DropdownMenuItem(value: true, child: Text('Completed')),
  //               DropdownMenuItem(value: false, child: Text('Pending')),
  //             ],
  //             onChanged: (value) {
  //               setState(() {
  //                 filter = TaskFilter(
  //                   isCompleted: value,
  //                   priority: filter.priority,
  //                 );
  //               });
  //             },
  //           ),
  //           const SizedBox(height: 16),
  //           DropdownButton<PriorityLevel?>(
  //             value: filter.priority,
  //             items: [
  //               const DropdownMenuItem(value: null, child: Text('All')),
  //               ...PriorityLevel.values.map(
  //                     (p) => DropdownMenuItem(value: p, child: Text(p.toString())),
  //               ),
  //             ],
  //             onChanged: (value) {
  //               setState(() {
  //                 filter = TaskFilter(
  //                   isCompleted: filter.isCompleted,
  //                   priority: value,
  //                 );
  //               });
  //             },
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Close'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tasks',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Filter by Status
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DropdownButtonFormField<bool?>(
                value: filter.isCompleted,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All')),
                  DropdownMenuItem(value: true, child: Text('Completed')),
                  DropdownMenuItem(value: false, child: Text('Pending')),
                ],
                onChanged: (value) {
                  setState(() {
                    filter = TaskFilter(
                      isCompleted: value,
                      priority: filter.priority,
                    );
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // Filter by Priority
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DropdownButtonFormField<PriorityLevel?>(
                value: filter.priority,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...PriorityLevel.values.map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(
                        p
                            .toString()
                            .split('.')
                            .last, // Display "Low", "Medium", "High"
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    filter = TaskFilter(
                      isCompleted: filter.isCompleted,
                      priority: value,
                    );
                  });
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showTaskDialog(BuildContext context, {Task? task}) {
    final titleController = TextEditingController(text: task?.title);
    final descriptionController =
        TextEditingController(text: task?.description);
    PriorityLevel priority = task?.priority ?? PriorityLevel.Low;
    DateTime dueDate = task?.dueDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(task == null ? 'Add Task' : 'Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              DropdownButton<PriorityLevel>(
                value: priority,
                items: PriorityLevel.values
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(
                          p
                              .toString()
                              .split('.')
                              .last, // Display "Low", "Medium", "High"
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setDialogState(() => priority = value!);
                },
              ),
              TextButton(
                onPressed: () async {
                  final newDate = await showDatePicker(
                    context: context,
                    initialDate: dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (newDate != null) {
                    setDialogState(() => dueDate = newDate);
                  }
                },
                child: Text(
                  'Due Date: ${dueDate.toString().split(' ')[0]}',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newTask = Task(
                  title: titleController.text,
                  description: descriptionController.text,
                  dueDate: dueDate,
                  priority: priority,
                  isCompleted: task?.isCompleted ?? false,
                );

                setState(() {
                  if (task == null) {
                    tasks.add(newTask);
                  } else {
                    final index = tasks.indexOf(task);
                    tasks[index] = newTask;
                  }
                });

                Navigator.pop(context);
              },
              child: Text(task == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskFilter {
  final bool? isCompleted;
  final PriorityLevel? priority;

  TaskFilter({
    this.isCompleted,
    this.priority,
  });
}
