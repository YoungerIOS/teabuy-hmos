import { AppRoute } from './RouteMap';

export class NavService {
  private static currentRoute: AppRoute = AppRoute.HOME;

  static go(route: AppRoute): void {
    NavService.currentRoute = route;
  }

  static getCurrentRoute(): AppRoute {
    return NavService.currentRoute;
  }
}
