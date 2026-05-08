import { generateUUID } from '../utils/UUIDUtil';

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
  weatherTemp: number | null;
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

  static fromJSON(obj: Record<string, any>): Postcard {
    const p = new Postcard(obj['locationName'], obj['recordedAt']);
    p.id = obj['id'];
    p.travelID = obj['travelID'] ?? null;
    p.photos = obj['photos'] ?? [];
    p.locationLat = obj['locationLat'] ?? null;
    p.locationLng = obj['locationLng'] ?? null;
    p.country = obj['country'] ?? null;
    p.city = obj['city'] ?? null;
    p.weatherCondition = obj['weatherCondition'] ?? null;
    p.weatherTemp = obj['weatherTemp'] ?? null;
    p.note = obj['note'] ?? null;
    p.tags = obj['tags'] ?? [];
    p.isFavorite = obj['isFavorite'] ?? false;
    p.createdAt = obj['createdAt'];
    return p;
  }

  toJSON(): object {
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
