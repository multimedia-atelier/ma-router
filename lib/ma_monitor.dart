import 'package:polymer/polymer.dart';
import 'lib_router.dart';

/**
 * A Polymer ma-monitor element.
 */
@CustomTag('ma-monitor')
class MaMonitor extends PolymerElement {

  // Constructor used to create instance of MaMonitor.
  MaMonitor.created() : super.created() {
  }

  attached() {
    super.attached();
    runRouting();
  }

  /// Called when an instance of ma-monitor is removed from the DOM.
  detached() {
    super.detached();
  }

}