import { HomeFeaturePage } from '../features/home/pages/HomePage';
import { LoginPage } from '../features/auth/pages/LoginPage';
import { UserStore } from '../core/store/UserStore';

@Entry
@Component
struct HomePage {
  @State private isLoggedIn: boolean = false;

  aboutToAppear(): void {
    this.isLoggedIn = UserStore.isLoggedIn();
  }

  build() {
    Column() {
      if (this.isLoggedIn) {
        HomeFeaturePage()
      } else {
        LoginPage({ isLoggedIn: $isLoggedIn })
      }
    }
    .width('100%')
    .height('100%')
  }
}
