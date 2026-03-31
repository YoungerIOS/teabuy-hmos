import { AppRoute } from '../../../router/RouteMap';
import { NavService } from '../../../router/NavService';
import { RouteParams } from '../../../router/RouteParams';
import { window, promptAction } from '@kit.ArkUI';
import { Colors } from '../../../core/ui/theme/Tokens';
import {
  NotificationItem,
  NotificationListData,
  NotificationReadOneData,
  NotificationRepository
} from '../data/NotificationRepository';

@Component
export struct NotificationPage {
  @Link currentRoute: AppRoute;
  @State private pageWidth: number = 375;
  @State private topSafeAreaPx: number = 0;
  @State private loading: boolean = false;
  @State private markingRead: boolean = false;
  @State private unreadCount: number = 0;
  @State private listData: NotificationListData = new NotificationListData();
  @State private nextCursor: string = '';
  private scroller: Scroller = new Scroller();

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
    void this.loadFirstPage();
  }

  private async loadFirstPage(): Promise<void> {
    if (this.loading) {
      return;
    }
    this.loading = true;
    try {
      const data = await NotificationRepository.list('', 30);
      this.listData = data;
      this.nextCursor = data.nextCursor || '';
      this.unreadCount = data.unreadCount;
    } catch (error) {
      console.error('Failed to load notifications:', error);
      this.listData = new NotificationListData();
      this.nextCursor = '';
      this.unreadCount = 0;
    } finally {
      this.loading = false;
    }
  }

  private async markAllRead(): Promise<void> {
    if (this.markingRead || this.unreadCount <= 0) {
      return;
    }

    const prevList = this.listData;
    const prevUnread = this.unreadCount;

    const next = new NotificationListData();
    next.nextCursor = this.nextCursor;
    next.unreadCount = 0;
    const rebuilt: NotificationItem[] = [];
    for (let i = 0; i < this.listData.items.length; i++) {
      const oldItem = this.listData.items[i];
      const item = new NotificationItem();
      item.id = oldItem.id;
      item.title = oldItem.title;
      item.content = oldItem.content;
      item.isRead = true;
      item.readAt = oldItem.readAt;
      item.createdAt = oldItem.createdAt;
      item.updatedAt = oldItem.updatedAt;
      item.linkType = oldItem.linkType;
      item.linkValue = oldItem.linkValue;
      item.type = oldItem.type;
      item.priority = oldItem.priority;
      rebuilt.push(item);
    }
    next.items = rebuilt;
    this.listData = next;
    this.unreadCount = 0;

    this.markingRead = true;
    try {
      const success = await NotificationRepository.readAll();
      if (!success) {
        this.listData = prevList;
        this.unreadCount = prevUnread;
        promptAction.showToast({ message: '操作失败，请重试' });
      }
    } catch (error) {
      console.error('Failed to mark notifications as read:', error);
      this.listData = prevList;
      this.unreadCount = prevUnread;
      promptAction.showToast({ message: '操作失败，请重试' });
    } finally {
      this.markingRead = false;
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

  private optimisticMarkRead(notificationId: string): void {
    const next = new NotificationListData();
    next.nextCursor = this.nextCursor;
    next.unreadCount = this.unreadCount;
    const rebuilt: NotificationItem[] = [];
    let changed = false;
    for (let i = 0; i < this.listData.items.length; i++) {
      const oldItem = this.listData.items[i];
      const item = new NotificationItem();
      item.id = oldItem.id;
      item.title = oldItem.title;
      item.content = oldItem.content;
      item.isRead = oldItem.isRead;
      item.readAt = oldItem.readAt;
      item.createdAt = oldItem.createdAt;
      item.updatedAt = oldItem.updatedAt;
      item.linkType = oldItem.linkType;
      item.linkValue = oldItem.linkValue;
      item.type = oldItem.type;
      item.priority = oldItem.priority;
      if (item.id === notificationId && !item.isRead) {
        item.isRead = true;
        changed = true;
      }
      rebuilt.push(item);
    }
    if (!changed) {
      return;
    }
    next.items = rebuilt;
    this.listData = next;
    this.unreadCount = this.unreadCount > 0 ? this.unreadCount - 1 : 0;
  }

  private syncReadOneInBackground(item: NotificationItem): void {
    if (item.isRead) {
      return;
    }
    void NotificationRepository.markRead(item.id).then((resp: NotificationReadOneData) => {
      if (resp.unreadCount >= 0) {
        this.unreadCount = resp.unreadCount;
      }
    }).catch((error: Error) => {
      console.error('Failed to mark one notification as read:', error);
      void this.loadFirstPage();
    });
  }

  private onOpenDetail(item: NotificationItem): void {
    this.optimisticMarkRead(item.id);
    this.syncReadOneInBackground(item);

    const params = new RouteParams();
    params.notificationId = item.id;
    params.notificationTitle = item.title || '系统消息';
    params.notificationContent = item.content || '';
    params.notificationCreatedAt = item.createdAt || '';
    NavService.go(AppRoute.NOTIFICATION_DETAIL, params);
    this.currentRoute = AppRoute.NOTIFICATION_DETAIL;
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

      Text('消息通知')
        .fontSize(this.s(18))
        .fontWeight(FontWeight.Medium)
        .fontColor('#4D716F')
        .margin({ left: this.s(4) });

      Blank();

      Text(this.markingRead ? '处理中...' : '全部已读')
        .fontSize(this.s(12))
        .fontColor(this.unreadCount > 0 ? '#4D716F' : '#A7B4AE')
        .onClick(() => {
          this.markAllRead();
        });
    }
    .width('100%')
    .height(this.s(52))
    .padding({ left: this.s(16), right: this.s(16) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Colors.pageBackground);
  }

  @Builder
  private UnreadBar() {
    Row() {
      Text(`未读消息 ${this.unreadCount}`)
        .fontSize(this.s(12))
        .fontColor('#5E7268');
      Blank();
      Text('点击刷新')
        .fontSize(this.s(11))
        .fontColor('#9AA7A0')
        .onClick(() => {
          void this.loadFirstPage();
        });
    }
    .width('100%')
    .padding({ left: this.s(16), right: this.s(16), top: this.s(8), bottom: this.s(8) })
    .backgroundColor('#EEF6F1');
  }

  @Builder
  private EmptyState() {
    Column() {
      Text('暂无消息')
        .fontSize(this.s(16))
        .fontColor('#9AA7A0')
        .margin({ top: this.s(48) });
      Text('后续系统通知会显示在这里')
        .fontSize(this.s(12))
        .fontColor('#B2BDB8')
        .margin({ top: this.s(8) });
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  private NotificationItemView(item: NotificationItem) {
    Row({ space: this.s(10) }) {
      Column() {
        Row()
          .width(this.s(8))
          .height(this.s(8))
          .borderRadius(this.s(4))
          .backgroundColor(item.isRead ? '#D8DFDB' : '#D85E53');
      }
      .width(this.s(14))
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .margin({ top: this.s(6) });

      Column({ space: this.s(6) }) {
        Text(item.title && item.title.length > 0 ? item.title : '系统消息')
          .fontSize(this.s(15))
          .fontWeight(item.isRead ? FontWeight.Regular : FontWeight.Medium)
          .fontColor(item.isRead ? '#556A61' : '#31463D')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });

        Text(item.content)
          .fontSize(this.s(13))
          .fontColor('#6F8178')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis });

        Text(this.formatTime(item.createdAt))
          .fontSize(this.s(11))
          .fontColor('#A1AEA8');
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding({ left: this.s(14), right: this.s(14), top: this.s(14), bottom: this.s(14) })
    .backgroundColor('#FFFFFF')
    .borderRadius(this.s(10))
    .margin({ top: this.s(10) })
    .onClick(() => {
      this.onOpenDetail(item);
    });
  }

  build() {
    Column() {
      this.TitleBar();
      this.UnreadBar();

      if (this.loading) {
        Row() {
          Text('加载中...')
            .fontSize(this.s(14))
            .fontColor('#9AA7A0');
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: this.s(24) });
      } else if (this.listData.items.length === 0) {
        this.EmptyState();
      } else {
        Scroll(this.scroller) {
          Column() {
            ForEach(this.listData.items, (item: NotificationItem) => {
              this.NotificationItemView(item);
            }, (item: NotificationItem) => `${item.id}_${item.isRead ? '1' : '0'}`);
          }
          .width('100%')
          .padding({ left: this.s(16), right: this.s(16), bottom: this.s(24) });
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off);
      }
    }
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
