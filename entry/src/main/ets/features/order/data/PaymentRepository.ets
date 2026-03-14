import { HttpClient } from '../../../core/network/HttpClient';
import { RequestConfig } from '../../../core/network/Interceptors';

export class PaymentResult {
  success: boolean = false;
  idempotent: boolean = false;
  status: string = '';
}

export class PaymentRepository {
  static async mockPay(orderNo: string, success: boolean): Promise<PaymentResult> {
    const req = new RequestConfig();
    req.path = '/payments/mock/pay';
    req.method = 'POST';
    req.hasBody = true;
    req.body = JSON.stringify({ orderNo, success });
    const result = await HttpClient.request<PaymentResult>(req);
    return result.data || new PaymentResult();
  }
}
