import { HttpClient } from '../../../core/network/HttpClient';
import { RequestConfig } from '../../../core/network/Interceptors';

export interface Address {
  id: string;
  recipient: string;
  phone: string;
  region: string;
  detail: string;
  isDefault: boolean;
}

export class AddressReq {
  recipient: string = '';
  phone: string = '';
  region: string = '';
  detail: string = '';
}

export interface ChinaArea {
  adcode: string;
  name: string;
  center?: string;
  level?: string;
  citycode?: string[];
  districts?: ChinaArea[];
}

export class AddressRepository {
  static async getAddresses(): Promise<Address[]> {
    const req = new RequestConfig();
    req.path = '/addresses';
    req.method = 'GET';
    const result = await HttpClient.request<Address[]>(req);
    return result.data || [];
  }

  static async createAddress(address: AddressReq): Promise<Address> {
    const req = new RequestConfig();
    req.path = '/addresses';
    req.method = 'POST';
    req.hasBody = true;
    req.body = JSON.stringify(address);
    const result = await HttpClient.request<Address>(req);
    return result.data;
  }

  static async setDefault(addressId: string): Promise<void> {
    const req = new RequestConfig();
    req.path = `/addresses/${addressId}/default`;
    req.method = 'POST';
    await HttpClient.request<void>(req);
  }

  static async deleteAddress(addressId: string): Promise<void> {
    const req = new RequestConfig();
    req.path = `/addresses/${addressId}`;
    req.method = 'DELETE';
    await HttpClient.request<void>(req);
  }

  // 中国行政区接口
  static async getProvinces(): Promise<ChinaArea[]> {
    const req = new RequestConfig();
    req.path = '/addresses/china/provinces';
    req.method = 'GET';
    const result = await HttpClient.request<ChinaArea[]>(req);
    return result.data || [];
  }

  static async getCities(provinceAdcode: string): Promise<ChinaArea[]> {
    const req = new RequestConfig();
    req.path = `/addresses/china/cities?province_adcode=${provinceAdcode}`;
    req.method = 'GET';
    const result = await HttpClient.request<ChinaArea[]>(req);
    return result.data || [];
  }

  static async getDistricts(cityAdcode: string): Promise<ChinaArea[]> {
    const req = new RequestConfig();
    req.path = `/addresses/china/districts?city_adcode=${cityAdcode}`;
    req.method = 'GET';
    const result = await HttpClient.request<ChinaArea[]>(req);
    return result.data || [];
  }
}
