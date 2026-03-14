export class RouteParams {
  productId: string = '';
  name: string = '';
  priceText: string = '';
  imageUrl: string = '';
  keyword: string = '';
  categoryKey: string = '';
  activityKey: string = '';
  topicKey: string = '';
  skuId: string = '';
  url: string = '';
  orderNo: string = '';
  totalCent: string = '';
  paymentRequired: string = '';

  static fromObject(source?: Record<string, string>): RouteParams {
    const params = new RouteParams();
    if (!source) {
      return params;
    }
    if (source.productId) {
      params.productId = source.productId;
    }
    if (source.name) {
      params.name = source.name;
    }
    if (source.priceText) {
      params.priceText = source.priceText;
    }
    if (source.imageUrl) {
      params.imageUrl = source.imageUrl;
    }
    if (source.keyword) {
      params.keyword = source.keyword;
    }
    if (source.categoryKey) {
      params.categoryKey = source.categoryKey;
    }
    if (source.activityKey) {
      params.activityKey = source.activityKey;
    }
    if (source.topicKey) {
      params.topicKey = source.topicKey;
    }
    if (source.skuId) {
      params.skuId = source.skuId;
    }
    if (source.url) {
      params.url = source.url;
    }
    if (source.orderNo) {
      params.orderNo = source.orderNo;
    }
    if (source.totalCent) {
      params.totalCent = source.totalCent;
    }
    if (source.paymentRequired) {
      params.paymentRequired = source.paymentRequired;
    }
    return params;
  }
}
