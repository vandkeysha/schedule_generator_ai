import 'package:flutter/material.dart';
import 'package:schedule_generator_ai/models/task.dart';
import 'package:schedule_generator_ai/services/gemini_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false; // kalau udh variablenya final maka ga bisa diubah lagi nilainya
  final List<Task> tasks = []; // wadah untuk menyimpan task yg akan di input user
  String ScheduleResult = ''; // wadah untuk menyimpan hasil jadwal yg dihasilkan oleh gemini
  final GeminiService geminiService = GeminiService(); // untuk mengakases layanan gemini

  Future<void> _generateSchedule() async{
    setState(() => isLoading = true);
    try {
      String schedule = await geminiService.generateSchedule(tasks);
      setState(() => ScheduleResult = schedule);
    } catch (e) {
      setState(() => ScheduleResult = e.toString());
    }
    setState(() =>  isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("Schedule Generator"),
        centerTitle: true, // untuk dia ketengah 
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
         _buildHeader(),
         // letakkan component add task card disini
         // letakkan component task list disini
         _buildGenerateButton()
        ],
      ),
    );
  }

  Widget _buildHeader(){
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer, // untuk mengambil warna dari tema yg sudah diatur di main.dart
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Plan your day faster with AI",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "Add your task and generate",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant
                  ),
                )
              ],
            )
          ),
          Chip(label: Text('${tasks.length} task'))
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return FilledButton.icon(
      onPressed: (isLoading || tasks.isEmpty) ? null : _generateSchedule, //kalau isloading true atau tasks kosong maka tombol disable
      icon: isLoading 
        ? SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
        : Icon(Icons.auto_awesome_rounded),
      label: Text(isLoading ? "Generating..." : "Generate Schedule"),
    );
  }
}
