import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'instruction.g.dart';

@JsonSerializable()
class Instruction {
  String id;
  String text;

  Instruction({required this.id, required this.text});

  /// A factory constructor to create a new, empty instruction with a unique ID.
  factory Instruction.empty() {
    return Instruction(id: Uuid().v4(), text: '');
  }

  factory Instruction.fromJson(Map<String, dynamic> json) =>
      _$InstructionFromJson(json);

  Map<String, dynamic> toJson() => _$InstructionToJson(this);
}
