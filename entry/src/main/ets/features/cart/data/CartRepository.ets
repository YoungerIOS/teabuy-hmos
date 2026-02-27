import { FeaturedListCard } from '../../home/data/HomeRepository';

export class CartItem {
  id: string;
  product: FeaturedListCard;
  quantity: number;
  selected: boolean;

  constructor(id: string, product: FeaturedListCard, quantity: number, selected: boolean) {
    this.id = id;
    this.product = product;
    this.quantity = quantity;
    this.selected = selected;
  }
}

export class Repository {
  // TODO: implement remote/local data sources.
}
