import { AppRoute } from './RouteMap';

export class NavService {
  private static currentRoute: AppRoute = AppRoute.HOME;
  private static routeHistory: AppRoute[] = [AppRoute.HOME];

  static go(route: AppRoute): void {
    NavService.routeHistory.push(route);
    NavService.currentRoute = route;
  }

  static back(): void {
    if (NavService.routeHistory.length > 1) {
      NavService.routeHistory.pop();
      NavService.currentRoute = NavService.routeHistory[NavService.routeHistory.length - 1];
    }
  }

  static getCurrentRoute(): AppRoute {
    return NavService.currentRoute;
  }
}
