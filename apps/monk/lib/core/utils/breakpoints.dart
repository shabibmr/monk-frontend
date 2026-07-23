import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';

enum ImBreakpoint { compact, medium, expanded }

ImBreakpoint breakpointForWidth(double width) {
  if (width < ImLayout.compactBreakpoint) return ImBreakpoint.compact;
  if (width < ImLayout.mediumBreakpoint) return ImBreakpoint.medium;
  return ImBreakpoint.expanded;
}

ImBreakpoint breakpointOf(BuildContext context) {
  return breakpointForWidth(MediaQuery.sizeOf(context).width);
}
