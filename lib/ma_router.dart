import 'dart:html';
import 'package:polymer/polymer.dart';
import 'lib_router.dart';
import 'lib_logging.dart';

/**
 * A Polymer ma-application element.
 */
@CustomTag('ma-router')
class MaRouter extends PolymerElement {

  Router router;

  /// Constructor used to create instance of MaApplication.
  MaRouter.created() : super.created() {
  }

  /*
   * Optional lifecycle methods - uncomment if needed.
   *

  /// Called when an instance of ma-application is inserted into the DOM.
  attached() {
    super.attached();
  }

  /// Called when an instance of ma-application is removed from the DOM.
  detached() {
    super.detached();
  }

  /// Called when an attribute (such as  a class) of an instance of
  /// ma-application is added, changed, or removed.
  attributeChanged(String name, String oldValue, String newValue) {
  }

  */

  /// Called when ma-application has been fully prepared (Shadow DOM created,
  /// property observers set up, event listeners attached).
  ready() {
    initLogging();
    router = new Router(this);
    router.processHashChange();
  }

}