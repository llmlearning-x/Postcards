import { preferences } from '@kit.ArkData';
import { context } from '../entryability/EntryAbility';
import { Travel, TravelStatus } from './Travel';
import { Postcard } from './Postcard';
import { UserStats } from './UserStats';
import { MockBackendSeeder } from './MockBackendSeeder';

const PREF_NAME = 'postcards_data';
const KEY_TRAVELS = 'travels';
const KEY_POSTCARDS = 'postcards';

type DataChangeListener = () => void;

class DataManagerClass {
  travels: Travel[] = [];
  postcards: Postcard[] = [];
  private pref: preferences.Preferences | null = null;
  private initialized: boolean = false;
  private listeners: DataChangeListener[] = [];

  init() {
    if (this.initialized) return;
    const ctx = context;
    if (!ctx) {
      console.warn('DataManager: context not available, using memory only');
      MockBackendSeeder.seed(this.travels, this.postcards);
      this.initialized = true;
      this.notifyListeners();
      return;
    }
    try {
      this.pref = preferences.getPreferencesSync(ctx, { name: PREF_NAME });
      this.load();
      if (this.travels.length === 0) {
        MockBackendSeeder.seed(this.travels, this.postcards);
        this.save();
      }
      this.initialized = true;
      this.notifyListeners();
    } catch (e) {
      console.error('DataManager init failed', e);
      MockBackendSeeder.seed(this.travels, this.postcards);
      this.initialized = true;
      this.notifyListeners();
    }
  }

  private load() {
    if (!this.pref) return;
    try {
      const travelsStr = this.pref.getSync(KEY_TRAVELS, '[]') as string;
      const postcardsStr = this.pref.getSync(KEY_POSTCARDS, '[]') as string;
      const travelsArr = JSON.parse(travelsStr) as Record<string, Object>[];
      const postcardsArr = JSON.parse(postcardsStr) as Record<string, Object>[];
      this.travels = travelsArr.map(t => Travel.fromJSON(t));
      this.postcards = postcardsArr.map(p => Postcard.fromJSON(p));
    } catch (e) {
      console.error('DataManager load failed', e);
      this.travels = [];
      this.postcards = [];
    }
  }

  save() {
    try {
      if (this.pref) {
        this.pref.putSync(KEY_TRAVELS, JSON.stringify(this.travels.map(t => t.toJSON())));
        this.pref.putSync(KEY_POSTCARDS, JSON.stringify(this.postcards.map(p => p.toJSON())));
        this.pref.flush();
      }
      this.notifyListeners();
    } catch (e) {
      console.error('DataManager save failed', e);
    }
  }

  addListener(listener: DataChangeListener) {
    if (!this.listeners.includes(listener)) {
      this.listeners.push(listener);
    }
  }

  removeListener(listener: DataChangeListener) {
    const index = this.listeners.indexOf(listener);
    if (index >= 0) {
      this.listeners.splice(index, 1);
    }
  }

  private notifyListeners() {
    for (const listener of this.listeners) {
      try {
        listener();
      } catch (e) {
        console.error('DataManager listener error', e);
      }
    }
  }

  // Travel operations
  addTravel(travel: Travel) {
    this.travels.push(travel);
    this.save();
  }

  updateTravel(travel: Travel) {
    const idx = this.travels.findIndex(t => t.id === travel.id);
    if (idx >= 0) {
      this.travels[idx] = travel;
      this.save();
    }
  }

  deleteTravel(travel: Travel) {
    const idx = this.travels.findIndex(t => t.id === travel.id);
    if (idx >= 0) {
      this.travels.splice(idx, 1);
      // cascade delete postcards
      this.postcards = this.postcards.filter(p => p.travelID !== travel.id);
      this.save();
    }
  }

  markAllTravelsAsNotCurrent() {
    for (const t of this.travels) {
      t.isCurrent = false;
      if (t.status === TravelStatus.ONGOING) {
        t.status = TravelStatus.PLANNED;
      }
      t.updatedAt = Date.now();
    }
  }

  setCurrentTravel(travel: Travel) {
    this.markAllTravelsAsNotCurrent();
    travel.isCurrent = true;
    if (travel.status !== TravelStatus.COMPLETED) {
      travel.status = TravelStatus.ONGOING;
    }
    travel.updatedAt = Date.now();
    this.save();
  }

  endTravel(travel: Travel) {
    travel.status = TravelStatus.COMPLETED;
    travel.isCurrent = false;
    travel.endDate = Date.now();
    travel.updatedAt = Date.now();
    const fallback = this.travels.find(t => t.id !== travel.id && t.status !== TravelStatus.COMPLETED);
    if (fallback) {
      fallback.isCurrent = true;
      fallback.status = TravelStatus.ONGOING;
      fallback.updatedAt = Date.now();
    }
    this.save();
  }

  // Postcard operations
  addPostcard(postcard: Postcard) {
    this.postcards.push(postcard);
    this.save();
  }

  updatePostcard(postcard: Postcard) {
    const idx = this.postcards.findIndex(p => p.id === postcard.id);
    if (idx >= 0) {
      this.postcards[idx] = postcard;
      this.save();
    }
  }

  deletePostcard(postcard: Postcard) {
    const idx = this.postcards.findIndex(p => p.id === postcard.id);
    if (idx >= 0) {
      this.postcards.splice(idx, 1);
      this.save();
    }
  }

  toggleFavorite(postcard: Postcard) {
    postcard.isFavorite = !postcard.isFavorite;
    this.save();
  }

  // Queries
  get currentTravel(): Travel | undefined {
    const current = this.travels.find(t => t.isCurrent);
    return current || this.travels.find(t => t.status === TravelStatus.ONGOING);
  }

  get otherTravels(): Travel[] {
    const current = this.currentTravel;
    return this.travels.filter(t => t.id !== current?.id).sort((a, b) => b.startDate - a.startDate);
  }

  get sortedTravels(): Travel[] {
    return this.travels.slice().sort((a, b) => b.startDate - a.startDate);
  }

  get sortedPostcards(): Postcard[] {
    return this.postcards.slice().sort((a, b) => b.recordedAt - a.recordedAt);
  }

  getTravelPostcards(travelId: string): Postcard[] {
    return this.postcards
      .filter(p => p.travelID === travelId)
      .sort((a, b) => b.recordedAt - a.recordedAt);
  }

  get uniqueCityCount(): number {
    const set = new Set(this.postcards.map(p => p.locationName.trim()).filter(s => s.length > 0));
    return set.size;
  }

  computeUserStats(): UserStats {
    const stats = new UserStats();
    stats.totalPostcards = this.postcards.length;
    stats.totalCities = new Set(this.postcards.map(p => p.city).filter(c => c && c.length > 0)).size;
    stats.totalCountries = new Set(this.postcards.map(p => p.country).filter(c => c && c.length > 0)).size;
    const firstDate = this.travels.map(t => t.createdAt).concat(this.postcards.map(p => p.createdAt)).sort((a, b) => a - b)[0];
    if (firstDate) {
      stats.joinedDays = Math.max(1, Math.floor((Date.now() - firstDate) / (1000 * 60 * 60 * 24)));
    }
    return stats;
  }
}

export const DataManager = new DataManagerClass();
