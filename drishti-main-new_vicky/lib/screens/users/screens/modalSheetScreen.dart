import 'package:flutter/material.dart';

class ParticipantListModal extends StatelessWidget {
  final String title;
  final List<Participant> participants;

  const ParticipantListModal({
    super.key,
    required this.title,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              '${participants.length} Participants Attending',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Participants',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: participants.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        NetworkImage(participants[index].avatarUrl),
                  ),
                  title: Text(participants[index].name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Participant {
  final String name;
  final String avatarUrl;

  Participant({required this.name, required this.avatarUrl});
}

// Example usage:
void showParticipantList(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) {
          return ParticipantListModal(
            title: 'Sudarshan Kriya',
            participants: [
              Participant(
                  name: 'Kundan Kumar Rao',
                  avatarUrl: 'https://example.com/avatar1.jpg'),
              Participant(
                  name: 'Amit Ranjan',
                  avatarUrl: 'https://example.com/avatar2.jpg'),
              Participant(
                  name: 'Aman Krishna',
                  avatarUrl: 'https://example.com/avatar3.jpg'),
              Participant(
                  name: 'Balbinder Singh',
                  avatarUrl: 'https://example.com/avatar4.jpg'),
              Participant(
                  name: 'Ram Chandar Prasad',
                  avatarUrl: 'https://example.com/avatar5.jpg'),
              Participant(
                  name: 'Kumari Laxmi',
                  avatarUrl: 'https://example.com/avatar6.jpg'),
              Participant(
                  name: 'Manisha Bharti',
                  avatarUrl: 'https://example.com/avatar7.jpg'),
            ],
          );
        },
      );
    },
  );
}
