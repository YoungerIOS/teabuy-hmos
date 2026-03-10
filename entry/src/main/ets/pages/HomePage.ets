import { HomeFeaturePage } from '../features/home/pages/HomePage';
import { LoginPage } from '../features/auth/pages/LoginPage';
import { UserStore } from '../core/store/UserStore';
import { AppRoute } from '../router/RouteMap';
import { NavService } from '../router/NavService';

@Entry
@Component
struct HomePage {
  @State private isLoggedIn: boolean = false;
  @State private currentRoute: AppRoute = AppRoute.HOME;
  @State private activeNav: number = 0;

  aboutToAppear(): void {
    this.isLoggedIn = UserStore.isLoggedIn();
  }

  onBackPress(): boolean {
    // 如果不在首页,返回上一页
    if (this.currentRoute !== AppRoute.HOME) {
      NavService.back();
      this.currentRoute = NavService.getCurrentRoute();
      return true; // 拦截返回键
    }
    return false; // 在首页,不拦截,允许退出应用
  }

  build() {
    Column() {
      if (this.isLoggedIn) {
        HomeFeaturePage({
          currentRoute: $currentRoute
        })
      } else {
        LoginPage({
          isLoggedIn: $isLoggedIn,
          currentRoute: $currentRoute,
          activeNav: $activeNav
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
