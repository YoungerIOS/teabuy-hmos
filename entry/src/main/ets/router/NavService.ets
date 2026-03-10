import { AppRoute } from './RouteMap';

export class NavService {
  private static currentRoute: AppRoute = AppRoute.HOME;
  private static routeHistory: AppRoute[] = [AppRoute.HOME];
  private static currentParams: Record<string, string> = {};

  static go(route: AppRoute, params?: Record<string, string>): void {
    NavService.routeHistory.push(route);
    NavService.currentRoute = route;
    if (params) {
      NavService.currentParams = params;
    } else {
      NavService.currentParams = {};
    }
  }

  static back(): void {
    if (NavService.routeHistory.length > 1) {
      NavService.routeHistory.pop();
      NavService.currentRoute = NavService.routeHistory[NavService.routeHistory.length - 1];
      NavService.currentParams = {};
    }
  }

  static getCurrentRoute(): AppRoute {
    return NavService.currentRoute;
  }

  static getParams(): Record<string, string> {
    return NavService.currentParams;
  }
}
