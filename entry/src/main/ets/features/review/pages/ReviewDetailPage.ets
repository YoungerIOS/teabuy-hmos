  import { AppRoute } from '../../../router/RouteMap';
  import { NavService } from '../../../router/NavService';
  import { Colors } from '../../../core/ui/theme/Tokens';

  class TeaDetail {
    name: string = '';
    description: string = '';
    imageUrl: string = '';
    price: string = '';
    rating: number = 5;
  }

  @Component
  export struct ReviewDetailPage {
    @Prop teaName: string = '银针绿茶';
    @Link selectedTeaDetail: string;
    @Link currentRoute: AppRoute;
    @State private currentIndex: number = 0;
    @State @Watch('onDisplayTeaNameChanged') private displayTeaName: string = '银针绿茶';
    @State @Watch('onDisplayDescriptionChanged') private displayDescription: string = '';
    @State private displayPrice: string = '';
    @State private displayRating: number = 5;
    private scroller: Scroller = new Scroller();
    private isProgrammaticScrolling: boolean = false; // 标志位：是否是程序触发的滚动

    private readonly statusBarMaskHeight: number = 44;
    private readonly headerTopInset: number = 56;
    private readonly headerHeight: number = 52;

    private readonly teaDetails: TeaDetail[] = [
      {
        name: '碧螺春',
        description: '         碧螺春是中国传统名茶，中国十大名茶之一，属于绿茶类。产于江苏省苏州市吴中区太湖的洞庭山（今苏州吴中区），所以又称"洞庭碧螺春"。碧螺春茶始于唐代，古称"吓煞人香"，后来清代康熙皇帝游览洞庭湖时，品尝后觉得名字不雅，便根据茶色碧绿、形曲如螺、采制于春季的特点，赐名"碧螺春"。',
        imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_3.png?width=422&quality=72',
          price: '¥128/50g',
          rating: 5
      },
      {
        name: '六师绿茶',
        description: '         六师绿茶产于安徽省六安市，是中国十大名茶之一。六师绿茶色泽嫩绿，条索紧细，汤色清澈明亮，香气清香持久，滋味鲜醇回甘。六师绿茶历史悠久，早在唐代就有记载，以其独特的品质和风格闻名于世。',
        imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_2.png?width=422&quality=72',
          price: '¥98/50g',
          rating: 4
      },
      {
        name: '高山绿茶',
        description: '         高山绿茶是指生长在海拔800米以上高山茶园的绿茶。由于高山云雾缭绕，昼夜温差大，茶树生长缓慢，叶片肥厚，内含物质丰富。高山绿茶色泽翠绿，香气清高持久，滋味鲜爽甘醇，汤色清澈明亮，叶底嫩绿匀亮。高山绿茶通常指生长在海拔500米至1500米以上高山环境的绿茶，因其独特的生态特征（云雾多、气温低、温差大），具有叶嫩、滋味鲜醇、香气高长、汤色翠绿等品质特征。常见著名品种包括黄山毛峰、庐山云雾、信阳毛尖等，是高品质绿茶的代表。高山绿茶是指生长在海拔800米以上高山茶园的绿茶。由于高山云雾缭绕，昼夜温差大，茶树生长缓慢，叶片肥厚，内含物质丰富。高山绿茶色泽翠绿，香气清高持久，滋味鲜爽甘醇，汤色清澈明亮，叶底嫩绿匀亮。高山绿茶通常指生长在海拔500米至1500米以上高山环境的绿茶，因其独特的生态特征（云雾多、气温低、温差大），具有叶嫩、滋味鲜醇、香气高长、汤色翠绿等品质特征。常见著名品种包括黄山毛峰、庐山云雾、信阳毛尖等，是高品质绿茶的代表。高山绿茶是指生长在海拔800米以上高山茶园的绿茶。由于高山云雾缭绕，昼夜温差大，茶树生长缓慢，叶片肥厚，内含物质丰富。高山绿茶色泽翠绿，香气清高持久，滋味鲜爽甘醇，汤色清澈明亮，叶底嫩绿匀亮。高山绿茶通常指生长在海拔500米至1500米以上高山环境的绿茶，因其独特的生态特征（云雾多、气温低、温差大），具有叶嫩、滋味鲜醇、香气高长、汤色翠绿等品质特征。常见著名品种包括黄山毛峰、庐山云雾、信阳毛尖等，是高品质绿茶的代表。高山绿茶是指生长在海拔800米以上高山茶园的绿茶。由于高山云雾缭绕，昼夜温差大，茶树生长缓慢，叶片肥厚，内含物质丰富。高山绿茶色泽翠绿，香气清高持久，滋味鲜爽甘醇，汤色清澈明亮，叶底嫩绿匀亮。高山绿茶通常指生长在海拔500米至1500米以上高山环境的绿茶，因其独特的生态特征（云雾多、气温低、温差大），具有叶嫩、滋味鲜醇、香气高长、汤色翠绿等品质特征。常见著名品种包括黄山毛峰、庐山云雾、信阳毛尖等，是高品质绿茶的代表。高山绿茶是指生长在海拔800米以上高山茶园的绿茶。由于高山云雾缭绕，昼夜温差大，茶树生长缓慢，叶片肥厚，内含物质丰富。高山绿茶色泽翠绿，香气清高持久，滋味鲜爽甘醇，汤色清澈明亮，叶底嫩绿匀亮。高山绿茶通常指生长在海拔500米至1500米以上高山环境的绿茶，因其独特的生态特征（云雾多、气温低、温差大），具有叶嫩、滋味鲜醇、香气高长、汤色翠绿等品质特征。常见著名品种包括黄山毛峰、庐山云雾、信阳毛尖等，是高品质绿茶的代表。高山绿茶是指生长在海拔800米以上高山茶园的绿茶。由于高山云雾缭绕，昼夜温差大，茶树生长缓慢，叶片肥厚，内含物质丰富。高山绿茶色泽翠绿，香气清高持久，滋味鲜爽甘醇，汤色清澈明亮，叶底嫩绿匀亮。高山绿茶通常指生长在海拔500米至1500米以上高山环境的绿茶，因其独特的生态特征（云雾多、气温低、温差大），具有叶嫩、滋味鲜醇、香气高长、汤色翠绿等品质特征。常见著名品种包括黄山毛峰、庐山云雾、信阳毛尖等，是高品质绿茶的代表。高山绿茶是指生长在海拔800米以上高山茶园的绿茶。由于高山云雾缭绕，昼夜温差大，茶树生长缓慢，叶片肥厚，内含物质丰富。高山绿茶色泽翠绿，香气清高持久，滋味鲜爽甘醇，汤色清澈明亮，叶底嫩绿匀亮。高山绿茶通常指生长在海拔500米至1500米以上高山环境的绿茶，因其独特的生态特征（云雾多、气温低、温差大），具有叶嫩、滋味鲜醇、香气高长、汤色翠绿等品质特征。常见著名品种包括黄山毛峰、庐山云雾、信阳毛尖等，是高品质绿茶的代表。高山绿茶是指生长在海拔800米以上高山茶园的绿茶。由于高山云雾缭绕，昼夜温差大，茶树生长缓慢，叶片肥厚，内含物质丰富。高山绿茶色泽翠绿，香气清高持久，滋味鲜爽甘醇，汤色清澈明亮，叶底嫩绿匀亮。高山绿茶通常指生长在海拔500米至1500米以上高山环境的绿茶，因其独特的生态特征（云雾多、气温低、温差大），具有叶嫩、滋味鲜醇、香气高长、汤色翠绿等品质特征。常见著名品种包括黄山毛峰、庐山云雾、信阳毛尖等，是高品质绿茶的代表。高山绿茶是指生长在海拔800米以上高山茶园的绿茶。由于高山云雾缭绕，昼夜温差大，茶树生长缓慢，叶片肥厚，内含物质丰富。高山绿茶色泽翠绿，香气清高持久，滋味鲜爽甘醇，汤色清澈明亮，叶底嫩绿匀亮。高山绿茶通常指生长在海拔500米至1500米以上高山环境的绿茶，因其独特的生态特征（云雾多、气温低、温差大），具有叶嫩、滋味鲜醇、香气高长、汤色翠绿等品质特征。常见著名品种包括黄山毛峰、庐山云雾、信阳毛尖等，是高品质绿茶的代表。高山绿茶是指生长在海拔800米以上高山茶园的绿茶。由于高山云雾缭绕，昼夜温差大，茶树生长缓慢，叶片肥厚，内含物质丰富。高山绿茶色泽翠绿，香气清高持久，滋味鲜爽甘醇，汤色清澈明亮，叶底嫩绿匀亮。高山绿茶通常指生长在海拔500米至1500米以上高山环境的绿茶，因其独特的生态特征（云雾多、气温低、温差大），具有叶嫩、滋味鲜醇、香气高长、汤色翠绿等品质特征。常见著名品种包括黄山毛峰、庐山云雾、信阳毛尖等，是高品质绿茶的代表。高山绿茶是指生长在海拔800米以上高山茶园的绿茶。由于高山云雾缭绕，昼夜温差大，茶树生长缓慢，叶片肥厚，内含物质丰富。高山绿茶色泽翠绿，香气清高持久，滋味鲜爽甘醇，汤色清澈明亮，叶底嫩绿匀亮。高山绿茶通常指生长在海拔500米至1500米以上高山环境的绿茶，因其独特的生态特征（云雾多、气温低、温差大），具有叶嫩、滋味鲜醇、香气高长、汤色翠绿等品质特征。常见著名品种包括黄山毛峰、庐山云雾、信阳毛尖等，是高品质绿茶的代表。',
        imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_5.png?width=422&quality=72',
          price: '¥158/50g',
          rating: 5
      },
      {
        name: '银针绿茶',
        description: '         银针茶银针茶是广西桂林茶叶科学研究所依据地处桂林尧山风景区优越的生态环境条件，选用福云六号，福云七号，福鼎大毫、凌云白毫茶等国家级优良茶树品种之鲜芽叶为原料，于八十年代末研制成功的色、香、味、形俱佳的名优特种茶，获1991年度浙江省国际茶文化节产品优良奖。银针，又叫白毫.....',
        imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_4.png?width=422&quality=72',
          price: '¥188/50g',
          rating: 5
      },
      {
        name: '炒青绿茶',
        description: '         炒青绿茶是绿茶的一种，是经过杀青、揉捻、干燥等工序制成的绿茶。炒青绿茶的外形扁平光滑，色泽翠绿，香气清高，滋味鲜爽，汤色清澈明亮。炒青绿茶是中国绿茶的主要品类之一，产量大，分布广。',
        imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_6.png?width=422&quality=72',
          price: '¥68/50g',
          rating: 4
      },
      {
        name: '白毛豪尖',
        description: '         白毛豪尖是中国传统名茶，属于绿茶类。产于四川省峨眉山地区，以其外形似针、白毫显露而得名。白毛豪尖色泽银绿，白毫显露，香气清高持久，滋味鲜爽回甘，汤色清澈明亮，叶底嫩绿匀亮。',
        imageUrl: 'https://nfzznasyztaontqmuhjq.supabase.co/storage/v1/render/image/public/product-images/home/home_review_bg_7.png?width=422&quality=72',
          price: '¥218/50g',
          rating: 5
      }
    ];

    // 更新显示内容的辅助方法
    private updateDisplayContent(index: number): void {
      if (index >= 0 && index < this.teaDetails.length) {
        console.log('updateDisplayContent: Setting displayTeaName to:', this.teaDetails[index].name);
        this.displayTeaName = this.teaDetails[index].name;
        this.displayDescription = this.teaDetails[index].description;
        this.displayPrice = this.teaDetails[index].price;
        this.displayRating = this.teaDetails[index].rating;
        this.selectedTeaDetail = this.teaDetails[index].name;
        console.log('updateDisplayContent: After update - displayTeaName:', this.displayTeaName);
      }
    }

    // @Watch 回调方法
    onDisplayTeaNameChanged(): void {
      console.log('onDisplayTeaNameChanged: displayTeaName changed to:', this.displayTeaName);
    }

    onDisplayDescriptionChanged(): void {
      console.log('onDisplayDescriptionChanged: displayDescription changed to:', this.displayDescription.substring(0, 20) + '...');
    }

    aboutToAppear(): void {
      console.log('ReviewDetailPage aboutToAppear selectedTeaDetail:', this.selectedTeaDetail);

      // 保存传入的 selectedTeaDetail 值，避免被 updateDisplayContent(0) 覆盖
      const initialTeaName = this.selectedTeaDetail;
      console.log('Saved initialTeaName:', initialTeaName);

      // 根据传入的 selectedTeaDetail 查找对应的索引
      const index = this.teaDetails.findIndex(item => item.name === initialTeaName);
      console.log('Found index for', initialTeaName, ':', index);

      if (index !== -1) {
        // 找到匹配的索引，使用该索引初始化显示内容
        this.currentIndex = index;
        this.updateDisplayContent(index);
        console.log('Setting currentIndex to:', index, 'displayTeaName:', this.displayTeaName);

        // 延迟滚动到对应位置
        setTimeout(() => {
          this.scrollToIndex(this.currentIndex);
        }, 100);
      } else {
        // 没有找到匹配的索引，使用默认值（第一个）
        console.log('Index not found, using default (0)');
        this.currentIndex = 0;
        if (this.teaDetails.length > 0) {
          this.updateDisplayContent(0);
        }
      }
    }

    private scrollToIndex(index: number): void {
      console.log('scrollToIndex called with index:', index);
      this.isProgrammaticScrolling = true; // 设置标志位
      const itemWidth = 231; // 211 (图片宽度) + 20 (间距)
      const scrollOffset = index * itemWidth;
      this.scroller.scrollTo({
        xOffset: scrollOffset,
        yOffset: 0,
        animation: {
          duration: 300,
          curve: Curve.EaseInOut
        }
      });
      // 动画结束后重置标志位
      setTimeout(() => {
        this.isProgrammaticScrolling = false;
        console.log('scrollToIndex: isProgrammaticScrolling reset to false');
      }, 350); // 稍微长于动画时间
    }

    build() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#71AD91');

        // 状态栏遮罩
        Row()
          .width('100%')
          .height(this.statusBarMaskHeight)
          .backgroundColor('#71AD91')
          .position({ x: 0, y: 0 });

        // 背景装饰矩形（浅色）
        Row()
          .width(449)
          .height(732)
          .backgroundColor('#F2F7F0')
          .position({ x: -56, y: 239 });

        // 底部纹样装饰
        Image($r('app.media.review_detail_pattern'))
          .width(590)
          .height(180)
          .objectFit(ImageFit.Contain)
          .opacity(0.8)
          .position({ x: 433, y: 283 })
          .rotate({ angle: 27.79 });

        // 茶叶图片滑动区域
        Scroll(this.scroller) {
          Row({ space: 20 }) {
            ForEach(this.teaDetails, (item: TeaDetail, index: number) => {
              Stack({ alignContent: Alignment.Center }) {
                // 白色背景卡片
                Row()
                  .width(211)
                  .height(211)
                  .backgroundColor(Colors.cardBackground)
                  .borderRadius(8)
                  .shadow({
                    radius: 0,
                    color: '#3A5453',
                    offsetX: 2,
                    offsetY: 2
                  });

                // 茶叶图片
                Image(item.imageUrl)
                  .width(211)
                  .height(211)
                  .borderRadius(8)
                  .objectFit(ImageFit.Cover);
              }
              .width(211)
              .height(211);
            }, (item: TeaDetail, index: number) => item.name + index);
          }
          .padding({ left: 82, right: 82 })
        }
        .width('100%')
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .position({ x: 0, y: 140 })
        .onScroll((xOffset: number, yOffset: number) => {
          void yOffset;
          // 如果是程序触发的滚动，不更新显示内容
          if (this.isProgrammaticScrolling) {
            console.log('onScroll: Skipping update due to programmatic scrolling');
            return;
          }
          
          // 滑动过程中不更新显示内容，只在 onScrollStop 时更新
          console.log('onScroll: xOffset =', xOffset, ', skipping update during scroll');
        })
        .onScrollStop(() => {
          console.log('onScrollStop: Scrolling stopped');
          // 滚动停止时，根据当前滚动位置更新显示内容
          const currentOffset = this.scroller.currentOffset().xOffset;
          const itemWidth = 231;
          const newIndex = Math.round(currentOffset / itemWidth);
          if (newIndex !== this.currentIndex && newIndex >= 0 && newIndex < this.teaDetails.length) {
            this.currentIndex = newIndex;
            console.log('onScrollStop: Updating to index:', newIndex);
            this.updateDisplayContent(newIndex);
          }
        });

        // 标题（水平居中）
        Text(this.displayTeaName)
          .fontSize(20)
          .fontColor(Colors.cardBackground)
          .fontWeight(FontWeight.Medium)
          .fontFamily('HarmonyOSSansSC')
          .position({ x: 0, y: 56 })
          .width('100%')
          .textAlign(TextAlign.Center);

        // 返回按钮
        Image($r('app.media.review_detail_back'))
          .width(16)
          .height(16)
          .objectFit(ImageFit.Contain)
          .position({ x: 18, y: 63 })
          .onClick(() => {
            this.currentRoute = AppRoute.REVIEW_LIST;
            NavService.go(AppRoute.REVIEW_LIST);
          });

        // 分享按钮
        Stack({ alignContent: Alignment.Center }) {
          // 边框
          Row()
            .width(28)
            .height(28)
            .borderRadius(2)
            .border({ width: 2, color: '#4D716F' });

          // 分享图标
          Image($r('app.media.review_detail_share'))
            .width(20)
            .height(21)
            .objectFit(ImageFit.Contain);
        }
        .width(28)
        .height(28)
        .position({ x: 314, y: 382 })
        .onClick(() => {
          // TODO: 实现分享功能
        });

        // 内容区域（使用flex布局）
        Column({ space: 16 }) {
          // 茶名、价格、评分区域
          Column({ space: 8 }) {
            // 茶名和价格
            Row() {
              Text(this.displayTeaName)
                .fontSize(18)
                .fontColor('#4D716F')
                .fontWeight(FontWeight.Bold)
                .fontFamily('HarmonyOSSansSC');
              
              Blank();
              
              Text(this.displayPrice)
                .fontSize(18)
                .fontColor('#D85E53')
                .fontWeight(FontWeight.Bold)
                .fontFamily('HarmonyOSSansSC');
            }
            .width('100%');
            
            // 评分（五星）
            Row({ space: 4 }) {
              ForEach([1, 2, 3, 4, 5], (star: number) => {
                Text('★')
                  .fontSize(16)
                  .fontColor(star <= this.displayRating ? '#FFD700' : '#CCCCCC')
                  .fontWeight(FontWeight.Bold);
              });
            }
            .width('100%')
            .justifyContent(FlexAlign.Start);
          }
          .width('100%')
          .padding({ left: 28, right: 28 });

          // 文本内容区域（可滚动）
          Scroll() {
            Text(this.displayDescription)
              .fontSize(12)
              .fontColor('#4D716F')
              .fontWeight(FontWeight.Bold)
              .fontFamily('SourceHanSerifCN')
              .lineHeight(36)
              .letterSpacing(0.9)
              .width('100%')
              .padding({ left: 28, right: 28 });
          }
          .width('100%')
          .height(200)  // 固定高度，超出时可滚动
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Off);
        }
        .width('100%')
        .position({ x: 0, y: 432 });

        // 按钮区域（固定在底部）
        Row({ space: 19 }) {
          // 评论区按钮
          Image($r('app.media.review_detail_comment_button'))
            .width(100)
            .height(40)
            .objectFit(ImageFit.Contain)
            .onClick(() => {
              // TODO: 跳转到评论区
            });

          // 立即购买按钮
          Image($r('app.media.review_detail_buy_button'))
            .width(200)
            .height(48)
            .objectFit(ImageFit.Contain)
            .onClick(() => {
              this.currentRoute = AppRoute.CHECKOUT;
              NavService.go(AppRoute.CHECKOUT);
            });
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .padding({ left: 28, right: 28, bottom: 20 })
        .position({ x: 0, y: '100%' })
        .translate({ y: -68 });  // 向上偏移按钮高度+底部边距

        // 占位符（用于布局平衡）
      }
      .width('100%')
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
    }
  }
