import 'package:equatable/equatable.dart';

class LeaderboardEntity extends Equatable {
  final String userId;
  final String userName;
  final int totalPoints;
  final int rank;

  const LeaderboardEntity({
    required this.userId,
    required this.userName,
    required this.totalPoints,
    required this.rank,
  });

  @override
  List<Object?> get props => [userId, userName, totalPoints, rank];
}
