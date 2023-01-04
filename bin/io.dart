import 'package:console/console.dart';

const ansiEscape = Console.ANSI_ESCAPE;
const ansiReset = "${ansiEscape}0m";

String rgb(String text, int color) {
  int r = color >> 16;
  int g = (color >> 8) & 0xFF;
  int b = color & 0xFF;

  return "${ansiEscape}38;2;$r;$g;${b}m$text$ansiReset";
}

E parseEnum<E extends Enum>(Iterable<E> values, String query, String enumName, [E Function(String)? getter]) {
  try {
    return (getter ?? values.byName)(query);
  } on ArgumentError {
    throw ArgumentError.value(query, enumName, "No such $enumName");
  }
}
