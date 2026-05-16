export interface Postcard {
  id: string
  travelId: string | null
  photoUrl: string
  locationName: string
  city: string
  country: string
  note: string
  toName: string | null
  stampDesign: string
  isFavorite: boolean
  isPublic: boolean
  stampCount: number
  recordedAt: number
  createdAt: number
}
