import { AppRoute } from './RouteMap';
import { RouteParams } from './RouteParams';

export class NavService {
  private static currentRoute: AppRoute = AppRoute.HOME;
  private static routeHistory: AppRoute[] = [AppRoute.HOME];
  private static currentParams: RouteParams = new RouteParams();

  static go(route: AppRoute, params?: RouteParams): void {
    NavService.routeHistory.push(route);
    NavService.currentRoute = route;
    if (params) {
      NavService.currentParams = params;
    } else {
      NavService.currentParams = new RouteParams();
    }
  }

  static back(): void {
    if (NavService.routeHistory.length > 1) {
      NavService.routeHistory.pop();
      NavService.currentRoute = NavService.routeHistory[NavService.routeHistory.length - 1];
      NavService.currentParams = new RouteParams();
    }
  }

  static getCurrentRoute(): AppRoute {
    return NavService.currentRoute;
  }

  static getParams(): RouteParams {
    return NavService.currentParams;
  }
}
