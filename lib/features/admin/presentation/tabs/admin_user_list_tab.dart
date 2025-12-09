import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserListTab extends StatefulWidget {
  const AdminUserListTab({super.key});

  @override
  State<AdminUserListTab> createState() => _AdminUserListTabState();
}

class _AdminUserListTabState extends State<AdminUserListTab>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();

  List<UserData> _allUsers = [];
  List<UserData> _filteredUsers = [];
  bool _isLoading = true;
  String _sortBy = 'joinDate'; // joinDate, name, email

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  /// 📥 Firestore에서 모든 사용자 불러오기
  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      final users = snapshot.docs.map((doc) {
        final data = doc.data();
        return UserData(
          uid: doc.id,
          email: data['email'] ?? '',
          displayName: data['displayName'] ?? '이름 없음',
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          inviteCode: data['inviteCode'],
          profileImageUrl: data['profileImageUrl'],
        );
      }).toList();

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('❌ 사용자 불러오기 실패: $e', Colors.red);
    }
  }

  /// 🔍 검색 필터링
  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers.where((user) {
          final email = user.email.toLowerCase();
          final name = user.displayName.toLowerCase();
          final searchQuery = query.toLowerCase();
          return email.contains(searchQuery) || name.contains(searchQuery);
        }).toList();
      }
      _applySorting();
    });
  }

  /// 📊 정렬 적용
  void _applySorting() {
    setState(() {
      switch (_sortBy) {
        case 'joinDate':
          _filteredUsers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case 'name':
          _filteredUsers.sort((a, b) => a.displayName.compareTo(b.displayName));
          break;
        case 'email':
          _filteredUsers.sort((a, b) => a.email.compareTo(b.email));
          break;
      }
    });
  }

  /// 📋 이메일 복사
  void _copyEmail(String email) {
    Clipboard.setData(ClipboardData(text: email));
    _showSnackBar('📋 $email 복사 완료', Colors.blue);
  }

  /// 📧 전체 이메일 CSV 복사
  void _copyAllEmailsAsCSV() {
    if (_filteredUsers.isEmpty) return;

    final csvBuffer = StringBuffer();
    csvBuffer.writeln('이름,이메일,가입일,초대코드');

    for (final user in _filteredUsers) {
      csvBuffer.writeln(
        '"${user.displayName}",${user.email},'
        '${_formatDate(user.createdAt)},'
        '${user.inviteCode ?? "없음"}',
      );
    }

    Clipboard.setData(ClipboardData(text: csvBuffer.toString()));
    _showSnackBar(
      '📊 ${_filteredUsers.length}명의 이메일을 CSV로 복사했습니다',
      Colors.green,
    );
  }

  /// 📧 이메일만 텍스트로 복사
  void _copyAllEmailsAsText() {
    if (_filteredUsers.isEmpty) return;

    final emails = _filteredUsers.map((user) => user.email).join('\n');
    Clipboard.setData(ClipboardData(text: emails));
    _showSnackBar('📋 ${_filteredUsers.length}개 이메일 복사 완료', Colors.blue);
  }

  /// 👤 사용자 상세 정보 보기
  void _showUserDetail(UserData user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: user.profileImageUrl != null
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user.profileImageUrl == null
                  ? const Icon(Icons.person, size: 24)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                user.displayName,
                style: const TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('📧 이메일', user.email),
              const SizedBox(height: 12),
              _buildDetailRow('📅 가입일', _formatDateTime(user.createdAt)),
              const SizedBox(height: 12),
              _buildDetailRow('🎫 초대코드', user.inviteCode ?? '사용 안 함'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          TextButton.icon(
            onPressed: () {
              _copyEmail(user.email);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.copy),
            label: const Text('이메일 복사'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        SelectableText(
          value,
          style: const TextStyle(fontFamily: 'Gmarket_sans', fontSize: 14),
        ),
      ],
    );
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        // 📊 통계 헤더
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '👥 전체 사용자',
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '총 ${_allUsers.length}명 가입',
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_filteredUsers.length}',
                  style: const TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 🔍 검색 & 정렬 & 복사
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 검색바
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '이름 또는 이메일 검색',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterUsers('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: _filterUsers,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadUsers,
                    tooltip: '새로고침',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 정렬 & 복사 버튼
              Row(
                children: [
                  // 정렬
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _sortBy,
                      decoration: InputDecoration(
                        labelText: '정렬',
                        prefixIcon: const Icon(Icons.sort),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'joinDate',
                          child: Text(
                            '가입일순',
                            style: TextStyle(fontFamily: 'Gmarket_sans'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'name',
                          child: Text(
                            '이름순',
                            style: TextStyle(fontFamily: 'Gmarket_sans'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'email',
                          child: Text(
                            '이메일순',
                            style: TextStyle(fontFamily: 'Gmarket_sans'),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _sortBy = value;
                            _applySorting();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // CSV 복사
                  IconButton.filled(
                    onPressed: _copyAllEmailsAsCSV,
                    icon: const Icon(Icons.table_chart),
                    tooltip: 'CSV 복사',
                    style: IconButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  const SizedBox(width: 4),

                  // 텍스트 복사
                  IconButton.filled(
                    onPressed: _copyAllEmailsAsText,
                    icon: const Icon(Icons.copy_all),
                    tooltip: '이메일 복사',
                    style: IconButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 📋 사용자 목록
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredUsers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '사용자가 없습니다',
                        style: TextStyle(
                          fontFamily: 'Gmarket_sans',
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    return _buildUserCard(user, index + 1);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUserCard(UserData user, int number) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showUserDetail(user),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 번호
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 프로필 이미지
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: user.profileImageUrl != null
                    ? NetworkImage(user.profileImageUrl!)
                    : null,
                child: user.profileImageUrl == null
                    ? Icon(Icons.person, color: Colors.grey.shade600)
                    : null,
              ),
              const SizedBox(width: 12),

              // 사용자 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: const TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(user.createdAt),
                          style: TextStyle(
                            fontFamily: 'Gmarket_sans',
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (user.inviteCode != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.card_giftcard,
                            size: 12,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.inviteCode!,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // 복사 버튼
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () => _copyEmail(user.email),
                tooltip: '이메일 복사',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// 📦 사용자 데이터 모델
class UserData {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final String? inviteCode;
  final String? profileImageUrl;

  UserData({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.inviteCode,
    this.profileImageUrl,
  });
}
