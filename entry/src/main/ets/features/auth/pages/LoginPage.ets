import { Colors } from '../../../core/ui/theme/Tokens';
import { AuthRepository } from '../data/AuthRepository';
import { UserStore } from '../../../core/store/UserStore';
import { ApiConfig } from '../../../core/network/ApiConfig';
import { AppRoute } from '../../../router/RouteMap';
import { NavService } from '../../../router/NavService';

@Component
export struct LoginPage {
  @Link isLoggedIn: boolean;
  @Link currentRoute: AppRoute;
  @Link activeNav: number;
  @State private username: string = ApiConfig.debugUsername;
  @State private password: string = ApiConfig.debugPassword;
  @State private loading: boolean = false;
  @State private errorText: string = '';
  @State private isRegisterMode: boolean = false;

  private async submitLogin(): Promise<void> {
    if (this.loading) {
      return;
    }
    if (this.username.trim().length === 0 || this.password.length === 0) {
      this.errorText = '请输入账号和密码';
      return;
    }
    this.loading = true;
    this.errorText = '';
    try {
      if (this.isRegisterMode) {
        // 注册
        const data = await AuthRepository.register(this.username.trim(), this.password);
        UserStore.setSession(data.accessToken, data.user.id);
        this.isLoggedIn = true;
        this.activeNav = 0;
        this.currentRoute = AppRoute.HOME;
        NavService.go(AppRoute.HOME);
      } else {
        // 登录
        const data = await AuthRepository.login(this.username.trim(), this.password);
        UserStore.setSession(data.accessToken, data.user.id);
        this.isLoggedIn = true;
        this.activeNav = 0;
        this.currentRoute = AppRoute.HOME;
        NavService.go(AppRoute.HOME);
      }
    } catch (err) {
      const value = err as Record<string, Object>;
      const msgObj = value['message'];
      this.errorText = msgObj !== undefined && msgObj !== null ? `${msgObj}` : (this.isRegisterMode ? '注册失败，请稍后重试' : '登录失败，请稍后重试');
    } finally {
      this.loading = false;
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Colors.brandPrimary);

      Column()
        .width(560)
        .height(420)
        .borderRadius(280)
        .backgroundColor(Colors.brandHalo)
        .position({ x: -90, y: -160 });

      Column({ space: 16 }) {
        Column({ space: 8 }) {
          Text('茶购')
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.cardBackground);
          Text('登录后开启你的好茶之旅')
            .fontSize(14)
            .fontColor(Colors.cardBackground)
            .opacity(0.9);
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 8, bottom: 8 });

        Column({ space: 12 }) {
          TextInput({ text: this.username, placeholder: '请输入账号' })
            .height(48)
            .fontSize(16)
            .backgroundColor(Colors.cardBackground)
            .borderRadius(12)
            .padding({ left: 12, right: 12 })
            .onChange((value: string) => {
              this.username = value;
            });

          TextInput({ text: this.password, placeholder: '请输入密码' })
            .height(48)
            .fontSize(16)
            .type(InputType.Password)
            .backgroundColor(Colors.cardBackground)
            .borderRadius(12)
            .padding({ left: 12, right: 12 })
            .onChange((value: string) => {
              this.password = value;
            });

          if (this.errorText.length > 0) {
            Text(this.errorText)
              .fontSize(12)
              .fontColor(Colors.danger)
              .maxLines(2);
          }

          Button(this.loading ? (this.isRegisterMode ? '注册中...' : '登录中...') : (this.isRegisterMode ? '注册' : '登录'))
            .width('100%')
            .height(46)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(Colors.cardBackground)
            .backgroundColor(Colors.brandAccent)
            .borderRadius(12)
            .enabled(!this.loading)
            .onClick(() => {
              this.submitLogin();
            });

          // 切换登录/注册模式
          Row() {
            Text(this.isRegisterMode ? '已有账号?立即登录' : '还没有账号?立即注册')
              .fontSize(14)
              .fontColor(Colors.brandAccent)
              .onClick(() => {
                this.isRegisterMode = !this.isRegisterMode;
                this.errorText = '';
              });
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 16 });
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Colors.cardBackground)
        .borderRadius(16);

        Blank().layoutWeight(1);

        Column() {
          Image($r('app.media.home_login_logo'))
            .width(100)
            .height(100)
            .objectFit(ImageFit.Contain);
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ bottom: 100 });
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 96 })
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}
