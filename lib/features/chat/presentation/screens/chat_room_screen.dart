import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class _Msg { final String id, text, senderId; final DateTime time;
  const _Msg({required this.id, required this.text, required this.senderId, required this.time}); }

final _msgProvider = StateProvider.family<List<_Msg>, String>((ref, id) => [
  _Msg(id:'1', text:'Hi! Do you have this item in stock?', senderId:'buyer', time: DateTime.now().subtract(const Duration(minutes:30))),
  _Msg(id:'2', text:'Yes we do! Which colour / size would you prefer?', senderId:'vendor', time: DateTime.now().subtract(const Duration(minutes:28))),
  _Msg(id:'3', text:'Black please. Can you deliver to Lusaka CBD?', senderId:'buyer', time: DateTime.now().subtract(const Duration(minutes:25))),
  _Msg(id:'4', text:'Absolutely! Delivery K25, 1-2 hours. Want to order?', senderId:'vendor', time: DateTime.now().subtract(const Duration(minutes:20))),
]);

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String chatId; final String vendorName;
  const ChatRoomScreen({super.key, required this.chatId, required this.vendorName});
  @override
  ConsumerState<ChatRoomScreen> createState() => _State();
}

class _State extends ConsumerState<ChatRoomScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  @override void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  void _send() {
    final t = _ctrl.text.trim(); if (t.isEmpty) return;
    ref.read(_msgProvider(widget.chatId).notifier).update(
        (s) => [...s, _Msg(id: DateTime.now().millisecondsSinceEpoch.toString(), text: t, senderId: 'buyer', time: DateTime.now())]);
    _ctrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds:300), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(_msgProvider(widget.chatId));
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => Navigator.pop(context)),
        title: Row(children: [
          CircleAvatar(radius:18, backgroundColor: AppColors.primaryContainer,
              child: Text(widget.vendorName.isNotEmpty ? widget.vendorName[0].toUpperCase() : 'V',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize:14))),
          const SizedBox(width:10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.vendorName.isEmpty ? 'Vendor' : widget.vendorName,
                style: const TextStyle(fontSize:15, fontWeight: FontWeight.w600)),
            Row(children: [
              Container(width:6, height:6, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
              const SizedBox(width:4),
              const Text('Online', style: TextStyle(fontSize:11, color: AppColors.success)),
            ]),
          ]),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined), onPressed: (){}),
          IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: (){}),
        ],
      ),
      body: Column(children: [
        Expanded(child: ListView.builder(
          controller: _scroll, padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (_, i) => _Bubble(msg: messages[i], isMine: messages[i].senderId != 'vendor'),
        )),
        Container(
          padding: const EdgeInsets.fromLTRB(12,8,12,8),
          decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: AppColors.grey200))),
          child: SafeArea(child: Row(children: [
            IconButton(icon: const Icon(Icons.attach_file_rounded, color: AppColors.grey500), onPressed: (){}),
            Expanded(child: TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                hintText: AppStrings.typeMessage,
                contentPadding: const EdgeInsets.symmetric(horizontal:14, vertical:10),
                fillColor: AppColors.grey100,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
              minLines:1, maxLines:4, textInputAction: TextInputAction.send, onSubmitted: (_) => _send(),
            )),
            const SizedBox(width:8),
            GestureDetector(onTap: _send,
                child: Container(width:40, height:40,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size:18))),
          ])),
        ),
      ]),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _Msg msg; final bool isMine;
  const _Bubble({required this.msg, required this.isMine});
  @override
  Widget build(BuildContext context) => Align(
    alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
      margin: const EdgeInsets.only(bottom:8),
      padding: const EdgeInsets.symmetric(horizontal:14, vertical:10),
      decoration: BoxDecoration(
        color: isMine ? AppColors.primary : Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMine ? 16 : 4), bottomRight: Radius.circular(isMine ? 4 : 16),
        ),
        border: isMine ? null : Border.all(color: AppColors.grey200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(msg.text, style: TextStyle(color: isMine ? Colors.white : null, fontSize:14, height:1.4)),
        const SizedBox(height:4),
        Text('${msg.time.hour.toString().padLeft(2,'0')}:${msg.time.minute.toString().padLeft(2,'0')}',
            style: TextStyle(fontSize:10, color: isMine ? Colors.white60 : AppColors.grey400)),
      ]),
    ),
  );
}
