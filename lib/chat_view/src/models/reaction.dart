class Reaction {
  Reaction({
    required this.reactions,
    required this.reactedUserIds,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) => Reaction(
        // Garante que 'reactions' é convertido para List<String>
        reactions: List<String>.from(json['reactions'] as List),
        // Garante que 'reactedUserIds' é convertido para List<String>
        reactedUserIds: List<String>.from(json['reactedUserIds'] as List),
      );

  final List<String> reactions;
  final List<String> reactedUserIds;

  Map<String, dynamic> toJson() => {
        'reactions': reactions,
        'reactedUserIds': reactedUserIds,
      };
}
