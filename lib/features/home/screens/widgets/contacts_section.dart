
// ============================================
// FILE: lib/features/home/screens/widgets/contacts_section.dart
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../data/models/user_model.dart';

class ContactsSection extends StatelessWidget {
  final List<UserModel> contacts;

  const ContactsSection({Key? key, required this.contacts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Contacts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.conversationList);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        if (contacts.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No contacts yet',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppConstants.textSecondary,
                      ),
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return _ContactAvatar(contact: contact);
              },
            ),
          ),
      ],
    );
  }
}

class _ContactAvatar extends StatelessWidget {
  final UserModel contact;

  const _ContactAvatar({required this.contact});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRouter.compose,
          arguments: {'receiverId': contact.id},
        );
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppConstants.primaryColor.withOpacity(0.2),
              backgroundImage: contact.photoUrl != null
                  ? NetworkImage(contact.photoUrl!)
                  : null,
              child: contact.photoUrl == null
                  ? Text(
                      contact.displayName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              contact.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}