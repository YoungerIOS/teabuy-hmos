import { AppRoute } from '../../../router/RouteMap';
import { NavService } from '../../../router/NavService';
import { Colors } from '../../../core/ui/theme/Tokens';
import { AddAddressSheet } from '../components/AddAddressSheet';
import { AddressRepository, Address } from '../data/AddressRepository';

@Component
export struct AddressPage {
  @Link currentRoute: AppRoute;
  @State private showAddAddress: boolean = false;
  @State private addresses: Address[] = [];
  @State private loading: boolean = false;

  async aboutToAppear(): Promise<void> {
    await this.loadAddresses();
  }

  private async loadAddresses(): Promise<void> {
    this.loading = true;
    try {
      this.addresses = await AddressRepository.getAddresses();
    } catch (error) {
      console.error('Failed to load addresses:', error);
    } finally {
      this.loading = false;
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
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

          // 标题居中
          Text('收货地址')
            .fontSize(18)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium);
        }
        .width('100%')
        .height(81)
        .padding({ top: 41 })

        // 地址列表
        if (this.loading) {
          Column() {
            Text('加载中...')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 100 });
          }
          .layoutWeight(1)
          .width('100%');
        } else if (this.addresses.length === 0) {
          Column() {
            Text('暂无收货地址')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 100 });
          }
          .layoutWeight(1)
          .width('100%');
        } else {
          List() {
            ForEach(this.addresses, (address: Address) => {
              ListItem() {
                this.AddressItem(address);
              }
              .margin({ bottom: 12 });
            });
          }
          .layoutWeight(1)
          .width('100%')
          .padding({ top: 16 });
        }

        // 添加地址按钮
        Row() {
          Text('新增收货地址')
            .fontSize(16)
            .fontColor(Color.White);
        }
        .width('100%')
        .height(44)
        .borderRadius(6)
        .backgroundColor(Colors.brandAccent)
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 20 })
        .onClick(() => {
          this.showAddAddress = true;
        });
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)
      .padding({ left: 30, right: 30 });

      // 新增地址弹窗
      AddAddressSheet({
        isVisible: $showAddAddress,
        onSaved: async () => {
          await this.loadAddresses();
        }
      });
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  AddressItem(address: Address) {
    Column() {
      Row() {
        Text(address.recipient)
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium);

        Text(address.phone)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ left: 12 });
      }
      .width('100%');

      Text(`${address.region} ${address.detail}`)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 8 })
        .width('100%');

      Row() {
        if (address.isDefault) {
          Text('默认')
            .fontSize(12)
            .fontColor(Colors.brandAccent)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor('#FFF5F5')
            .borderRadius(4);
        }

        Blank();

        Text('设为默认')
          .fontSize(14)
          .fontColor('#666666')
          .onClick(async () => {
            try {
              await AddressRepository.setDefault(address.id);
              await this.loadAddresses();
            } catch (error) {
              console.error('Failed to set default:', error);
            }
          });
      }
      .width('100%')
      .margin({ top: 12 });
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F8F8F8')
    .borderRadius(8);
  }
}
