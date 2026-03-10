import { AppRoute } from '../../../router/RouteMap';
import { NavService } from '../../../router/NavService';
import { Colors } from '../../../core/ui/theme/Tokens';
import webview from '@ohos.web.webview';

@Component
export struct WebViewPage {
  @Link currentRoute: AppRoute;
  @State url: string = '';
  @State loadError: string = '';
  controller: webview.WebviewController = new webview.WebviewController();

  aboutToAppear(): void {
    // 从 NavService 获取参数
    const params = NavService.getParams();
    console.log('WebViewPage params:', JSON.stringify(params));
    if (params && params.url) {
      this.url = params.url;
      console.log('WebViewPage URL:', this.url);
    } else {
      this.loadError = 'No URL provided';
      console.error('WebViewPage: No URL provided');
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Stack() {
        // 返回按钮
        Image($r('app.media.review_detail_back'))
          .width(20)
          .height(20)
          .objectFit(ImageFit.Contain)
          .position({ x: 20, y: 55 })
          .onClick(() => {
            console.log('WebViewPage back button clicked');
            NavService.back();
            this.currentRoute = NavService.getCurrentRoute();
            console.log('WebViewPage currentRoute after back:', this.currentRoute);
          });

        // 标题居中
        Text('详情')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium);
      }
      .width('100%')
      .height(81)
      .padding({ top: 41 })
      .alignContent(Alignment.Center);

      // 错误提示或 WebView
      if (this.loadError) {
        Column() {
          Text('加载失败')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ bottom: 8 })
          Text(this.loadError)
            .fontSize(14)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.url) {
        Web({ src: this.url, controller: this.controller })
          .width('100%')
          .layoutWeight(1)
          .onPageBegin((event) => {
            console.log('WebView onPageBegin:', event?.url);
          })
          .onPageEnd((event) => {
            console.log('WebView onPageEnd:', event?.url);
          })
          .onErrorReceive((event) => {
            console.error('WebView onErrorReceive:', event?.error?.getErrorInfo());
            this.loadError = event?.error?.getErrorInfo() || 'Unknown error';
          })
          .onHttpErrorReceive((event) => {
            console.error('WebView onHttpErrorReceive:', event?.response?.getResponseCode(), event?.response?.getReasonMessage());
          })
          .javaScriptAccess(true)
          .domStorageAccess(true)
          .fileAccess(true)
          .imageAccess(true)
          .mixedMode(MixedMode.All)
      } else {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White);
  }
}
