import { AppRoute } from '../../../router/RouteMap';
import { NavService } from '../../../router/NavService';
import { window } from '@kit.ArkUI';
import { Colors } from '../../../core/ui/theme/Tokens';
import { NotificationRepository } from '../data/NotificationRepository';

@Component
export struct NotificationDetailPage {
  @Link currentRoute: AppRoute;
  @State private pageWidth: number = 375;
  @State private topSafeAreaPx: number = 0;
  @State private notificationId: string = '';
  @State private title: string = '';
  @State private content: string = '';
  @State private createdAt: string = '';

  private s(value: number): number {
    return value * this.pageWidth / 375;
  }

  aboutToAppear(): void {
    window.getLastWindow(getContext(this)).then((win: window.Window) => {
      const avoidArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      this.topSafeAreaPx = px2vp(avoidArea.topRect.height);
    }).catch(() => {
      this.topSafeAreaPx = 44;
    });

    const params = NavService.getParams();
    this.notificationId = params.notificationId || '';
    this.title = params.notificationTitle || '系统消息';
    this.content = params.notificationContent || '';
    this.createdAt = this.formatTime(params.notificationCreatedAt || '');
    if (this.notificationId.length > 0) {
      void this.loadDetail();
    }
  }

  private async loadDetail(): Promise<void> {
    try {
      const detail = await NotificationRepository.getOne(this.notificationId);
      if (detail.title && detail.title.length > 0) {
        this.title = detail.title;
      }
      if (detail.content && detail.content.length > 0) {
        this.content = detail.content;
      }
      this.createdAt = this.formatTime(detail.createdAt || this.createdAt);
    } catch (error) {
      console.error('Failed to load notification detail:', error);
    }
  }

  private formatTime(input: string): string {
    if (!input || input.length === 0) {
      return '';
    }
    const parts = input.split('T');
    if (parts.length < 2) {
      return input;
    }
    const time = parts[1].replace('Z', '');
    return `${parts[0]} ${time.slice(0, 8)}`;
  }

  @Builder
  private TitleBar() {
    Row() {
      Row() {
        Image($rawfile('ic_checkout_back.svg'))
          .width(this.s(14))
          .height(this.s(14))
          .objectFit(ImageFit.Contain);
      }
      .width(this.s(36))
      .height(this.s(36))
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        NavService.back();
        this.currentRoute = NavService.getCurrentRoute();
      });

      Text('消息详情')
        .fontSize(this.s(18))
        .fontWeight(FontWeight.Medium)
        .fontColor('#4D716F')
        .margin({ left: this.s(4) });

      Blank();
    }
    .width('100%')
    .height(this.s(52))
    .padding({ left: this.s(16), right: this.s(16) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Colors.pageBackground);
  }

  build() {
    Column() {
      this.TitleBar();

      Scroll() {
        Column({ space: this.s(10) }) {
          Text(this.title)
            .width('100%')
            .fontSize(this.s(20))
            .fontWeight(FontWeight.Medium)
            .fontColor('#31463D');

          if (this.createdAt.length > 0) {
            Text(this.createdAt)
              .width('100%')
              .fontSize(this.s(12))
              .fontColor('#9AA7A0');
          }

          Text(this.content.length > 0 ? this.content : '暂无详情内容')
            .width('100%')
            .fontSize(this.s(15))
            .lineHeight(this.s(24))
            .fontColor('#4F635A')
            .margin({ top: this.s(8) });
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: this.s(16), right: this.s(16), top: this.s(12), bottom: this.s(28) });
      }
      .width('100%')
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off);
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
    .padding({ top: this.topSafeAreaPx })
    .backgroundColor(Colors.pageBackground)
    .onAreaChange((oldValue, newValue) => {
      void oldValue;
      const width = Number(newValue.width);
      if (width > 0) {
        this.pageWidth = width;
      }
    });
  }
}
