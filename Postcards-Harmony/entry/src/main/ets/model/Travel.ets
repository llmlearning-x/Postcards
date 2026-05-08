import { generateUUID } from '../utils/UUIDUtil';

export enum TravelStatus {
  ONGOING = 'ONGOING',
  COMPLETED = 'COMPLETED',
  PLANNED = 'PLANNED'
}

export class Travel {
  id: string;
  title: string;
  destination: string;
  startDate: number; // timestamp
  endDate: number | null;
  status: TravelStatus;
  isCurrent: boolean;
  coverImageURL: string | null;
  createdAt: number;
  updatedAt: number;

  constructor(title: string, destination: string, startDate: number, isCurrent: boolean = true) {
    this.id = generateUUID();
    this.title = title;
    this.destination = destination;
    this.startDate = startDate;
    this.endDate = null;
    this.status = TravelStatus.ONGOING;
    this.isCurrent = isCurrent;
    this.coverImageURL = null;
    this.createdAt = Date.now();
    this.updatedAt = Date.now();
  }

  static fromJSON(obj: Record<string, any>): Travel {
    const t = new Travel(obj['title'], obj['destination'], obj['startDate'], obj['isCurrent']);
    t.id = obj['id'];
    t.endDate = obj['endDate'] ?? null;
    t.status = obj['status'] as TravelStatus;
    t.coverImageURL = obj['coverImageURL'] ?? null;
    t.createdAt = obj['createdAt'];
    t.updatedAt = obj['updatedAt'];
    return t;
  }

  toJSON(): object {
    return {
      id: this.id,
      title: this.title,
      destination: this.destination,
      startDate: this.startDate,
      endDate: this.endDate,
      status: this.status,
      isCurrent: this.isCurrent,
      coverImageURL: this.coverImageURL,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt
    };
  }
}
