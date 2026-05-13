import { generateUUID } from '../utils/UUIDUtil';

export enum TravelStatus {
  ONGOING = 'ONGOING',
  COMPLETED = 'COMPLETED',
  PLANNED = 'PLANNED'
}

interface TravelJSON {
  id: string;
  title: string;
  destination: string;
  startDate: number;
  endDate: number | null;
  isCurrent: boolean;
  status: string;
  coverImageURL: string | null;
  createdAt: number;
  updatedAt: number;
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

  static fromJSON(obj: Record<string, Object>): Travel {
    const t = new Travel(obj['title'] as string, obj['destination'] as string, obj['startDate'] as number, obj['isCurrent'] as boolean);
    t.id = obj['id'] as string;
    t.endDate = (obj['endDate'] as number) || null;
    t.status = obj['status'] as TravelStatus;
    t.coverImageURL = (obj['coverImageURL'] as string) || null;
    t.createdAt = obj['createdAt'] as number;
    t.updatedAt = obj['updatedAt'] as number;
    return t;
  }

  toJSON(): TravelJSON {
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
