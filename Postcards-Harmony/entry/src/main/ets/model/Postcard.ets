import { generateUUID } from '../utils/UUIDUtil';

interface PostcardJSON {
  id: string;
  travelID: string | null;
  locationName: string;
  locationLat: number | null;
  locationLng: number | null;
  country: string | null;
  city: string | null;
  photos: string[];
  recordedAt: number;
  weatherCondition: string | null;
  weatherTemp: string | null;
  note: string | null;
  tags: string[];
  isFavorite: boolean;
  createdAt: number;
}

export class Postcard {
  id: string;
  travelID: string | null;
  photos: string[];
  locationName: string;
  locationLat: number | null;
  locationLng: number | null;
  country: string | null;
  city: string | null;
  recordedAt: number;
  weatherCondition: string | null;
  weatherTemp: string | null;
  note: string | null;
  tags: string[];
  isFavorite: boolean;
  createdAt: number;

  constructor(locationName: string, recordedAt: number) {
    this.id = generateUUID();
    this.travelID = null;
    this.photos = [];
    this.locationName = locationName;
    this.locationLat = null;
    this.locationLng = null;
    this.country = null;
    this.city = null;
    this.recordedAt = recordedAt;
    this.weatherCondition = null;
    this.weatherTemp = null;
    this.note = null;
    this.tags = [];
    this.isFavorite = false;
    this.createdAt = Date.now();
  }

  static fromJSON(obj: Record<string, Object>): Postcard {
    const p = new Postcard(obj['locationName'] as string, obj['recordedAt'] as number);
    p.id = obj['id'] as string;
    p.travelID = (obj['travelID'] as string) || null;
    p.photos = (obj['photos'] as string[]) || [];
    p.locationLat = (obj['locationLat'] as number) || null;
    p.locationLng = (obj['locationLng'] as number) || null;
    p.country = (obj['country'] as string) || null;
    p.city = (obj['city'] as string) || null;
    p.weatherCondition = (obj['weatherCondition'] as string) || null;
    p.weatherTemp = (obj['weatherTemp'] as string) || null;
    p.note = (obj['note'] as string) || null;
    p.tags = (obj['tags'] as string[]) || [];
    p.isFavorite = (obj['isFavorite'] as boolean) || false;
    p.createdAt = obj['createdAt'] as number;
    return p;
  }

  toJSON(): PostcardJSON {
    return {
      id: this.id,
      travelID: this.travelID,
      photos: this.photos,
      locationName: this.locationName,
      locationLat: this.locationLat,
      locationLng: this.locationLng,
      country: this.country,
      city: this.city,
      recordedAt: this.recordedAt,
      weatherCondition: this.weatherCondition,
      weatherTemp: this.weatherTemp,
      note: this.note,
      tags: this.tags,
      isFavorite: this.isFavorite,
      createdAt: this.createdAt
    };
  }
}
