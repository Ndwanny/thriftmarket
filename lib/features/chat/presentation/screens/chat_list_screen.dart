import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final chats = [
      _Chat(id:'c1', name:'TechHub ZM', lastMsg:'Your order is on the way!', time:'2h ago', unread:2),
      _Chat(id:'c2', name:'SneakerWorld', lastMsg:'Yes, we have size 42 in stock.', time:'Yesterday', unread:0),
      _Chat(id:'c3', name:'FreshMart', lastMsg:'Thank you for your order!', time:'2 days ago', unread:0),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.messages, style: Theme.of(context).textTheme.titleMedium)),
      body: chats.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.grey300),
              const SizedBox(height: 16),
              Text(AppStrings.noMessages, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text(AppStrings.noMessagesDesc, style: TextStyle(color: AppColors.grey500)),
            ]))
          : ListView.separated(
              padding: const EdgeInsets.all(16), itemCount: chats.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
                leading: CircleAvatar(radius: 24, backgroundColor: AppColors.primaryContainer,
                    child: Text(chats[i].name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))),
                title: Text(chats[i].name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(chats[i].lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.grey500)),
                trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(chats[i].time, style: const TextStyle(fontSize: 11, color: AppColors.grey400)),
                  if (chats[i].unread > 0) ...[const SizedBox(height: 4),
                    Container(width: 18, height: 18,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: Center(child: Text('${chats[i].unread}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))))],
                ]),
                onTap: () => context.push('${RouteNames.chatRoom}/${chats[i].id}',
                    extra: {'vendorName': chats[i].name}),
              ),
            ),
    );
  }
}
class _Chat { final String id, name, lastMsg, time; final int unread;
  const _Chat({required this.id, required this.name, required this.lastMsg, required this.time, required this.unread});
}
