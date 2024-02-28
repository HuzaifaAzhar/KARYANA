import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class Feedback {
  final String feedback;
  final String user;

  Feedback({required this.feedback, required this.user});

  Map<String, dynamic> toJson() {
    return {
      'feedback': feedback,
      'user': user,
    };
  }
}

void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ),
  );
}

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _displayFeedback(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showSnackbar(context, 'You need to be logged in to view feedback.');
      return;
    }

    final snapshot = await FirebaseDatabase.instance
        .ref()
        .child('feedback')
        .orderByChild('user')
        .equalTo(user.uid)
        .get();

    if (snapshot.value == null) {
      showSnackbar(context, 'You have not submitted any feedback yet.');
      return;
    }

    final List<Feedback> feedbackList = [];
    (snapshot.value as Map<String, dynamic>).forEach((key, value) {
      final feedback = Feedback(
        feedback: value['feedback'] ?? '',
        user: value['user'] ?? '',
      );
      feedbackList.add(feedback);
    });

    final feedbackStrings = feedbackList.map((feedback) => '- ${feedback.feedback}\n ').toList();
    final feedbackMessage = feedbackStrings.join('\n');
    showSnackbar(context, 'Your Feedback is ${feedbackMessage}');
  }


  void _submitFeedback() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showSnackbar(context, 'You need to be logged in to submit feedback.');
      return;
    }

    final feedbackText = _feedbackController.text.trim();
    if (feedbackText.isEmpty) {
      showSnackbar(context, 'Please enter some feedback.');
      return;
    }


    final feedback = Feedback(
      feedback: feedbackText,
      user: user.uid,
    );

    try {
      final reference =
      FirebaseDatabase.instance.ref().child('feedback').push();
      await reference.set(feedback.toJson());
      showSnackbar(context, 'Feedback submitted!');
    } catch (e) {
      showSnackbar(context, 'Error submitting feedback: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackground(context),
      appBar: AppBar(
        title: const Text('Submit Feedback'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Feedback',
              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(width: 250,
              child: TextField(
                controller: _feedbackController,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your feedback here',
                ),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: const Text('Submit Feedback'),
            ),
            // const SizedBox(height:20),
            // ElevatedButton(
            //   onPressed:(){ _displayFeedback(context);},
            //   child: const Text('Display Feedback'),
            // ),
          ],
        ),
      ),
    );
  }
}