import 'package:polymer/polymer.dart';

import 'lib_router.dart';

/**
 * A Polymer ma-form element.
 */
@CustomTag('ma-activity')
class MaActivity extends PolymerElement implements RouteListener {

  @observable String parentRoute = null;
  @observable String myRoute = null;
  @observable RouterEvent lastRouterEvent;
  @observable Map<String,Object> routerVariables;
  @observable bool visible;

  /// Constructor used to create instance of MaForm.
  MaActivity.created() : super.created() {
  }

  void routeChanged(RouterEvent routerEvent) {
    parentRoute = routerEvent.fullParentRoute;
    myRoute = routerEvent.fullTargetRoute;
    routerVariables = routerEvent.routerVariables;
    visible = routerEvent.routeMatched;

    if (visible) {
      fire("route-visible", detail: routerEvent.routerVariables);
    }
  }
  
}