import 'package:flutter/material.dart';
import 'package:docuverse/models/study_plan_model.dart';
import 'package:docuverse/utils/helpers.dart';

class SmartPlanPage extends StatelessWidget {
  const SmartPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final studyPlan = ModalRoute.of(context)!.settings.arguments as StudyPlan;

    return Scaffold(
      appBar: AppBar(title: Text(studyPlan.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Study Plan: ${Helpers.formatDate(studyPlan.startDate)} - ${Helpers.formatDate(studyPlan.endDate)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: studyPlan.sessions.length,
              itemBuilder: (context, index) {
                final session = studyPlan.sessions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Helpers.formatDate(session.date),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Chip(
                              label: Text(
                                '${session.duration.inMinutes} min',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.white),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          session.topic,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(session.description),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Checkbox(
                              value: session.isCompleted,
                              onChanged: (value) {},
                            ),
                            const Text('Completed'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}