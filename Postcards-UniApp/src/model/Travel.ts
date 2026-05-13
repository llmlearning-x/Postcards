export enum TravelStatus {
  PLANNED = 'planned',
  ONGOING = 'ongoing',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled'
}

export interface Travel {
  id: string
  title: string
  destination: string
  startDate: number
  endDate: number
  createdAt: number
  status: TravelStatus
  isCurrent: boolean
  description?: string
}
