import { AppRoute } from '../../../router/RouteMap';
import { NavService } from '../../../router/NavService';
import { Colors } from '../../../core/ui/theme/Tokens';
import { AuthRepository } from '../../auth/data/AuthRepository';

@Component
export struct SettingsPage {
  @Link currentRoute: AppRoute;

  build() {
    Column() {
      // 顶部导航栏
      Stack() {
        // 返回按钮
        Row() {
          Image($r('app.media.review_detail_back'))
          .width(20)
          .height(20)
          .objectFit(ImageFit.Contain)

          .onClick(() => {
            NavService.back();
            this.currentRoute = NavService.getCurrentRoute();
          });
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .padding({ left: 20 })

        // 标题居中
        Text('设置')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium);
      }
      .width('100%')
      .height(81)
      .padding({ top: 41 })
      // .justifyContent(FlexAlign.Center)

      // 收货地址按钮
      Row() {
        Text('收货地址')
          .fontSize(16)
          .fontColor('#333333');
        Blank();
        Image($r('app.media.review_detail_back_right'))
          .width(16)
          .height(16)
          .objectFit(ImageFit.Contain);
      }
      .width('100%')
      .height(44)
      .backgroundColor('#F8F8F8')
      .justifyContent(FlexAlign.Center)
      .padding({ left: 16, right: 16 })
      .margin({ bottom: 10 })
      .onClick(() => {
        this.currentRoute = AppRoute.ADDRESS;
        NavService.go(AppRoute.ADDRESS);
      });

      // 退出登录按钮
      Row() {
        Text('退出登录')
          .fontSize(16)
          .fontColor('#D85E53');
      }
      .width('100%')
      .height(44)
      .backgroundColor('#F8F8F8')
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        AlertDialog.show({
          title: '提示',
          message: '确定要退出登录吗?',
          primaryButton: {
            value: '取消',
            action: () => {}
          },
          secondaryButton: {
            value: '确定',
            fontColor: '#D85E53',
            action: async () => {
              try {
                await AuthRepository.logout();
                // 退出登录成功,跳转到登录页
                this.currentRoute = AppRoute.LOGIN;
                NavService.go(AppRoute.LOGIN);
              } catch (error) {
                console.error('Logout failed:', error);
              }
            }
          }
        });
      });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White);
  }
}
