import 'dart:html';
import 'package:polymer/polymer.dart';

import 'lib_logging.dart';

List<String> _buildNormalizedRouteParts(String route) {
  List<String> parts = route.split("/");
  List<String> parsedRoute = new List();
  parts.forEach((String part) {
    if (part != null) {
      part = part.trim();
      if (part.length > 0) {
        parsedRoute.add(part);
      }
    }
  });

  return parsedRoute;
}

List<Router> _allRouters = [];

registerRouter(Router router) {
  _allRouters.add(router);
}

runRouting() {
  _allRouters.forEach((Router r) {
    r.processHashChange();
  });
}

/**
 */
class Router extends Observable {

  Element _routingRoot;

  @observable Map<String, Object> routerVariables = {};

  @observable String currentRoute;

  Router([Element this._routingRoot]) {
    if (_routingRoot == null) {
      _routingRoot = document.body;
    }
    document.onLoad.listen((_) {
      //maLog.fine("onLoad processing hash");
      processHashChange();
    });
    window.onHashChange.listen((_) {
      //maLog.fine("onHashChange processing hash");
      processHashChange();
    });

    registerRouter(this);
  }

  processHashChange() {
    String hash = window.location.hash;
    //maLog.info("Processing hash: '${hash}'");
    if (hash.startsWith("#")) {
      hash = hash.substring(1, hash.length);
    }

    processHash(hash);
  }

  processHash(String hash) {
    List<String> normalizedHashParts = _buildNormalizedRouteParts(hash);
    routerVariables = {};

    List<_RoutePart> contextRoute = [];

    processRoutingForElement(normalizedHashParts, contextRoute, _routingRoot, null);

    //maLog.info("Router variables: ${routerVariables}");

    currentRoute = "/"+normalizedHashParts.join("/");
  }

  processRoutingForElement(List<String> normalizedHashParts, List<_RoutePart> contextRoute, Element element, Element routeParent) {

    if (element == null) return;

    List<_RoutePart> elementContextRoute = contextRoute;

    bool continueToChildren = true;

    if (element.getAttribute("route") != null) {
      // this element requires routing

      // let's build elements full route List<_RoutePart>
      List<String> relativeElementRoute = _buildNormalizedRouteParts(element.getAttribute("route"));
      elementContextRoute = [];
      elementContextRoute.addAll(contextRoute);
      relativeElementRoute.forEach((String part) {
        elementContextRoute.add(new _RoutePart(part));
      });

      // let's prepare routing event
      RouterEvent routerEvent = new RouterEvent();
      routerEvent.routerVariables = const {}; // we will replace it later - if needed
      routerEvent.targetElement = element;
      routerEvent.routingRootElement = _routingRoot;
      routerEvent.parentElement = routeParent;

      // let's build full parent's and local route /a/b/c/ - user can use it to render a hrefs
      StringBuffer parentBuffer = new StringBuffer();
      StringBuffer targetBuffer = new StringBuffer();
      for(int a=0; a < elementContextRoute.length;a++) {
        if (a < normalizedHashParts.length) {
          String stringPart = normalizedHashParts[a];
          if (a < contextRoute.length) {
            if (a!=0) parentBuffer.write("/");
            parentBuffer.write(stringPart);
          }
          if (a!=0) targetBuffer.write("/");
          targetBuffer.write(stringPart);
        } else {
          // full element's route is longer then current hash, but it can happen, if the last part of the hash is not mandatory
        }
      }

      routerEvent.fullParentRoute = "/"+parentBuffer.toString();
      routerEvent.fullTargetRoute = "/"+targetBuffer.toString();

      int mandatoryElementRouteLength = elementContextRoute.length;
      if (!elementContextRoute.last.mandatory) {
        mandatoryElementRouteLength -= 1;
      }

      if (mandatoryElementRouteLength > normalizedHashParts.length) {
        // element's route is longer than current hash, element is too deep
        routerEvent.routeMatched = false;
        sendRouterEvent(routerEvent);
        continueToChildren = false; // we can skip all children

      } else {
        bool shouldBeVisible = true;
        Map<String, Object> variables = {};
        for (int a = 0; a < elementContextRoute.length;a++) {
          _RoutePart pattern = elementContextRoute[a];
          if (a == normalizedHashParts.length) {
            if (!pattern.mandatory) {
              // we are exatly 1 part longer then current hash, but the last part is NOT mandatory, element is visible
              break;
            } else {
              // we are exatly 1 part longer then current hash, but the last part IS mandatory, element is hiddne
              shouldBeVisible = false;
              break;
            }
          }

          String match = pattern.regExp.stringMatch(normalizedHashParts[a]);
          if (match == normalizedHashParts[a]) {
            // match!
            if (pattern.isVariable) {
              var value = pattern.type == _RouteVariableType_INT ? int.parse(match) : match;
              variables[pattern.variable] = value;
            }
          } else {
            // should not be visible, unless it's a last part of the route and is not mandatory
            shouldBeVisible = false;
            break;
          }
        }
        routerVariables.addAll(variables);
        routerEvent.routeMatched = shouldBeVisible;
        routerEvent.routerVariables = variables;
        sendRouterEvent(routerEvent);
        continueToChildren = shouldBeVisible;
      }
    }

    if (continueToChildren) {
      element.children.forEach((Element child) {
        processRoutingForElement(normalizedHashParts, elementContextRoute, child, element);
      });
      if (element.shadowRoot != null && element.shadowRoot.children != null) {
        element.shadowRoot.children.forEach((Element child) {
          processRoutingForElement(normalizedHashParts, elementContextRoute, child, element);
        });
      }
    }
  }

  sendRouterEvent(RouterEvent event) {
    if (!event.routeMatched) {
      event.fullTargetRoute = null;
    }

    //maLog.info("Sending event: ${event}");

    // TODO: support for paper view pager, whatever is it's name
    Element e = event.targetElement;
    if (e is RouteListener) {
      (e as RouteListener).routeChanged(event);
    }
    if (event.routeMatched) {
      e.attributes.remove("ma-router-invisible");
    } else {
      e.attributes["ma-router-invisible"] = "ma-router-invisible";
    }
  }

}

abstract class RouteListener {

  void routeChanged(RouterEvent routerEvent);

}

class RouterEvent {

  bool routeMatched;

  Element routingRootElement;
  Router sourceRouter;

  Element parentElement;
  Element targetElement;

  String fullParentRoute;
  String fullTargetRoute;

  Map<String, Object> routerVariables;

  String toString() {
    return "matched=${routeMatched}[parent=${fullParentRoute}, target=${fullTargetRoute}, variables=${routerVariables}]";
  }

}

/**
 * One segment of an element's route.
 */
class _RoutePart {

  RegExp regExp;
  bool isVariable;
  String variable;
  String type;
  bool mandatory = true;

  _RoutePart(String routePart) {
    if (routePart.startsWith("?")) {
      mandatory = false;
      routePart = routePart.substring(1, routePart.length);
    }
    if (routePart.startsWith(r"{") && routePart.endsWith(r"}")) {
      routePart = routePart.substring(1, routePart.length-1);
      isVariable = true;
      if (routePart.endsWith(":int")) {
        routePart = routePart.substring(0, routePart.length-4);
        regExp = new RegExp("[0-9]*");
        type = _RouteVariableType_INT;
      } else {
        regExp = new RegExp(".*");
        type = _RouteVariableType_STRING;
      }
      variable = routePart;
    } else {
      regExp = new RegExp(routePart);
      isVariable = false;
      variable = null;
      type = null;
    }

  }

}

const _RouteVariableType_STRING = "STRING";
const _RouteVariableType_INT = "INT";