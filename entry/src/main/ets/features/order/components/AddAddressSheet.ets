import { Colors } from '../../../core/ui/theme/Tokens';
import { AddressRepository, AddressReq, ChinaArea } from '../data/AddressRepository';

@Component
export struct AddAddressSheet {
  @Link isVisible: boolean;
  onSaved?: () => void;

  @State private recipient: string = '';
  @State private phone: string = '';
  @State private selectedProvince: ChinaArea | null = null;
  @State private selectedCity: ChinaArea | null = null;
  @State private selectedDistrict: ChinaArea | null = null;
  @State private detailAddress: string = '';
  @State private showProvincePicker: boolean = false;
  @State private showCityPicker: boolean = false;
  @State private showDistrictPicker: boolean = false;
  @State private saving: boolean = false;

  @State private provinces: ChinaArea[] = [];
  @State private cities: ChinaArea[] = [];
  @State private districts: ChinaArea[] = [];
  @State private loadingProvinces: boolean = false;
  @State private loadingCities: boolean = false;
  @State private loadingDistricts: boolean = false;

  async aboutToAppear(): Promise<void> {
    await this.loadProvinces();
  }

  private async loadProvinces(): Promise<void> {
    this.loadingProvinces = true;
    try {
      this.provinces = await AddressRepository.getProvinces();
    } catch (error) {
      console.error('Failed to load provinces:', error);
    } finally {
      this.loadingProvinces = false;
    }
  }

  private async loadCities(provinceAdcode: string): Promise<void> {
    this.loadingCities = true;
    try {
      this.cities = await AddressRepository.getCities(provinceAdcode);
    } catch (error) {
      console.error('Failed to load cities:', error);
    } finally {
      this.loadingCities = false;
    }
  }

  private async loadDistricts(cityAdcode: string): Promise<void> {
    this.loadingDistricts = true;
    try {
      this.districts = await AddressRepository.getDistricts(cityAdcode);
    } catch (error) {
      console.error('Failed to load districts:', error);
    } finally {
      this.loadingDistricts = false;
    }
  }

  build() {
    if (this.isVisible) {
      Column() {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.5)')
          .onClick(() => {
            this.isVisible = false;
          });

        // 弹窗内容
        Column() {
          // 标题栏
          Row() {
            Text('取消')
              .fontSize(16)
              .fontColor('#666666')
              .onClick(() => {
                this.isVisible = false;
              });

            Text('新增收货地址')
              .fontSize(18)
              .fontColor('#333333')
              .fontWeight(FontWeight.Medium);

            Text(this.saving ? '保存中...' : '保存')
              .fontSize(16)
              .fontColor(this.saving ? '#999999' : Colors.brandAccent)
              .onClick(() => {
                if (!this.saving) {
                  this.saveAddress();
                }
              });
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 16, right: 16, top: 16, bottom: 16 });

          // 表单内容
          Column({ space: 12 }) {
            // 收件人
            Row() {
              Text('收件人')
                .fontSize(16)
                .fontColor('#333333')
                .width(60);

              TextInput({ text: this.recipient, placeholder: '请输入收件人姓名' })
                .fontSize(16)
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .onChange((value: string) => {
                  this.recipient = value;
                });
            }
            .width('100%')
            .height(50)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#F8F8F8')
            .borderRadius(8);

            // 手机号
            Row() {
              Text('手机号')
                .fontSize(16)
                .fontColor('#333333')
                .width(60);

              TextInput({ text: this.phone, placeholder: '请输入手机号' })
                .fontSize(16)
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .type(InputType.PhoneNumber)
                .onChange((value: string) => {
                  this.phone = value;
                });
            }
            .width('100%')
            .height(50)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#F8F8F8')
            .borderRadius(8);

            // 省份选择
            Row() {
              Text('省份')
                .fontSize(16)
                .fontColor('#333333')
                .width(60);

              Text(this.selectedProvince?.name || '请选择')
                .fontSize(16)
                .fontColor(this.selectedProvince ? '#333333' : '#999999')
                .layoutWeight(1);

              Image($r('app.media.profile_icon_arrow_3x'))
                .width(16)
                .height(16);
            }
            .width('100%')
            .height(50)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#F8F8F8')
            .borderRadius(8)
            .onClick(() => {
              this.showProvincePicker = true;
              this.showCityPicker = false;
              this.showDistrictPicker = false;
            });

            // 城市选择
            Row() {
              Text('城市')
                .fontSize(16)
                .fontColor('#333333')
                .width(60);

              Text(this.selectedCity?.name || '请选择')
                .fontSize(16)
                .fontColor(this.selectedCity ? '#333333' : '#999999')
                .layoutWeight(1);

              Image($r('app.media.profile_icon_arrow_3x'))
                .width(16)
                .height(16);
            }
            .width('100%')
            .height(50)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#F8F8F8')
            .borderRadius(8)
            .enabled(this.selectedProvince !== null)
            .opacity(this.selectedProvince !== null ? 1 : 0.5)
            .onClick(() => {
              if (this.selectedProvince) {
                this.showProvincePicker = false;
                this.showCityPicker = true;
                this.showDistrictPicker = false;
              }
            });

            // 区县选择
            Row() {
              Text('区县')
                .fontSize(16)
                .fontColor('#333333')
                .width(60);

              Text(this.selectedDistrict?.name || '请选择')
                .fontSize(16)
                .fontColor(this.selectedDistrict ? '#333333' : '#999999')
                .layoutWeight(1);

              Image($r('app.media.profile_icon_arrow_3x'))
                .width(16)
                .height(16);
            }
            .width('100%')
            .height(50)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#F8F8F8')
            .borderRadius(8)
            .enabled(this.selectedCity !== null)
            .opacity(this.selectedCity !== null ? 1 : 0.5)
            .onClick(() => {
              if (this.selectedCity) {
                this.showProvincePicker = false;
                this.showCityPicker = false;
                this.showDistrictPicker = true;
              }
            });

            // 详细地址
            TextInput({ text: this.detailAddress, placeholder: '请输入详细地址(街道门牌号等)' })
              .fontSize(16)
              .height(50)
              .backgroundColor('#F8F8F8')
              .borderRadius(8)
              .padding({ left: 16, right: 16 })
              .onChange((value: string) => {
                this.detailAddress = value;
              });
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 });

          // 选择器列表
          if (this.showProvincePicker) {
            this.PickerList(
              this.provinces,
              this.loadingProvinces,
              (area: ChinaArea) => {
                this.selectedProvince = area;
                this.selectedCity = null;
                this.selectedDistrict = null;
                this.showProvincePicker = false;
                this.loadCities(area.adcode);
              }
            );
          } else if (this.showCityPicker) {
            this.PickerList(
              this.cities,
              this.loadingCities,
              (area: ChinaArea) => {
                this.selectedCity = area;
                this.selectedDistrict = null;
                this.showCityPicker = false;
                this.loadDistricts(area.adcode);
              }
            );
          } else if (this.showDistrictPicker) {
            this.PickerList(
              this.districts,
              this.loadingDistricts,
              (area: ChinaArea) => {
                this.selectedDistrict = area;
                this.showDistrictPicker = false;
              }
            );
          }
        }
        .width('100%')
        .height('85%')
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: 16, topRight: 16 })
        .position({ x: 0, y: '15%' });
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 });
    }
  }

  private async saveAddress(): Promise<void> {
    // 验证
    if (this.recipient.trim().length === 0) {
      AlertDialog.show({ message: '请输入收件人姓名' });
      return;
    }
    if (this.phone.trim().length === 0) {
      AlertDialog.show({ message: '请输入手机号' });
      return;
    }
    if (!this.selectedProvince || !this.selectedCity || !this.selectedDistrict) {
      AlertDialog.show({ message: '请选择完整的省市区' });
      return;
    }
    if (this.detailAddress.trim().length === 0) {
      AlertDialog.show({ message: '请输入详细地址' });
      return;
    }

    this.saving = true;
    try {
      const address = new AddressReq();
      address.recipient = this.recipient.trim();
      address.phone = this.phone.trim();
      address.region = `${this.selectedProvince.name} ${this.selectedCity.name} ${this.selectedDistrict.name}`;
      address.detail = this.detailAddress.trim();

      await AddressRepository.createAddress(address);

      // 重置表单
      this.recipient = '';
      this.phone = '';
      this.selectedProvince = null;
      this.selectedCity = null;
      this.selectedDistrict = null;
      this.detailAddress = '';

      this.isVisible = false;

      if (this.onSaved) {
        this.onSaved();
      }
    } catch (error) {
      console.error('Failed to save address:', error);
      AlertDialog.show({ message: '保存失败,请重试' });
    } finally {
      this.saving = false;
    }
  }

  @Builder
  PickerList(items: ChinaArea[], loading: boolean, onSelect: (area: ChinaArea) => void) {
    Column() {
      if (loading) {
        Text('加载中...')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 20 });
      } else {
        List() {
          ForEach(items, (item: ChinaArea) => {
            ListItem() {
              Text(item.name)
                .fontSize(16)
                .fontColor('#333333')
                .width('100%')
                .height(50)
                .padding({ left: 16, right: 16 })
                .onClick(() => {
                  onSelect(item);
                });
            }
          });
        }
        .width('100%')
        .height(350)
        .backgroundColor('#F8F8F8')
        .borderRadius(8);
      }
    }
    .width('100%')
    .margin({ top: 16 });
  }
}
