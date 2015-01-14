import 'package:polymer/polymer.dart';

import 'ma_activity.dart';

/**
 * A Polymer ma-template-test element.
 */
@CustomTag('test-routing')
class MaTemplateTest extends MaActivity {

  @observable String count = "1";

  /// Constructor used to create instance of MaTemplateTest.
  MaTemplateTest.created() : super.created() {
  }

  void debugRouterEvent(event, detail, node) {
    print("Child is visible, with these router variables: ${detail}");
  }

  String toString() {
    return "test-routing";
  }
  
}
