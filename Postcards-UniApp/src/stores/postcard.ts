import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { Travel } from '@/model/Travel'
import { TravelStatus } from '@/model/Travel'
import type { Postcard } from '@/model/Postcard'
import { mockTravels, mockPostcards } from '@/data/mockData'
import { StorageUtil } from '@/utils/storage'
import { AppConfig } from '@/config/app'

export const usePostcardStore = defineStore('postcard', () => {
  const travels = ref<Travel[]>([])
  const postcards = ref<Postcard[]>([])
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  const sortedTravels = computed(() => {
    return [...travels.value].sort((a, b) => b.createdAt - a.createdAt)
  })

  const sortedPostcards = computed(() => {
    return [...postcards.value].sort((a, b) => b.recordedAt - a.createdAt)
  })

  const currentTravel = computed(() => {
    return travels.value.find(t => t.isCurrent) || travels.value.find(t => t.status === TravelStatus.ONGOING)
  })

  // 从本地存储加载数据
  function loadFromStorage(): void {
    try {
      isLoading.value = true
      error.value = null

      const savedTravels = StorageUtil.get<Travel[]>(AppConfig.storageKeys.TRAVELS, [])
      const savedPostcards = StorageUtil.get<Postcard[]>(AppConfig.storageKeys.POSTCARDS, [])

      if (savedTravels.length === 0 && savedPostcards.length === 0) {
        // 如果没有存储数据，使用模拟数据
        travels.value = mockTravels
        postcards.value = mockPostcards
        saveToStorage()
      } else {
        travels.value = savedTravels
        postcards.value = savedPostcards
      }
    } catch (err) {
      console.error('Load from storage error:', err)
      error.value = '数据加载失败'
    } finally {
      isLoading.value = false
    }
  }

  // 保存到本地存储
  function saveToStorage(): void {
    try {
      StorageUtil.set(AppConfig.storageKeys.TRAVELS, travels.value)
      StorageUtil.set(AppConfig.storageKeys.POSTCARDS, postcards.value)
    } catch (err) {
      console.error('Save to storage error:', err)
    }
  }

  // 初始化数据
  function initData(): void {
    if (travels.value.length === 0 && postcards.value.length === 0) {
      loadFromStorage()
    }
  }

  function getTravelById(id: string): Travel | undefined {
    return travels.value.find(t => t.id === id)
  }

  function getPostcardsByTravel(travelId: string): Postcard[] {
    return postcards.value.filter(p => p.travelId === travelId)
  }

  function getPostcardById(id: string): Postcard | undefined {
    return postcards.value.find(p => p.id === id)
  }

  function addTravel(travel: Travel): void {
    travels.value.push(travel)
    saveToStorage()
  }

  function updateTravel(id: string, updates: Partial<Travel>): boolean {
    const index = travels.value.findIndex(t => t.id === id)
    if (index !== -1) {
      travels.value[index] = { ...travels.value[index], ...updates }
      saveToStorage()
      return true
    }
    return false
  }

  function addPostcard(postcard: Postcard): void {
    postcards.value.push(postcard)
    saveToStorage()
  }

  function updatePostcard(id: string, updates: Partial<Postcard>): boolean {
    const index = postcards.value.findIndex(p => p.id === id)
    if (index !== -1) {
      postcards.value[index] = { ...postcards.value[index], ...updates }
      saveToStorage()
      return true
    }
    return false
  }

  function toggleFavorite(postcardId: string): boolean {
    const postcard = postcards.value.find(p => p.id === postcardId)
    if (postcard) {
      postcard.isFavorite = !postcard.isFavorite
      saveToStorage()
      return true
    }
    return false
  }

  function deleteTravel(travelId: string): boolean {
    const index = travels.value.findIndex(t => t.id === travelId)
    if (index !== -1) {
      travels.value.splice(index, 1)
      // 同时删除关联的明信片
      postcards.value = postcards.value.filter(p => p.travelId !== travelId)
      saveToStorage()
      return true
    }
    return false
  }

  function deletePostcard(postcardId: string): boolean {
    const index = postcards.value.findIndex(p => p.id === postcardId)
    if (index !== -1) {
      postcards.value.splice(index, 1)
      saveToStorage()
      return true
    }
    return false
  }

  function clearError(): void {
    error.value = null
  }

  function resetData(): void {
    travels.value = mockTravels
    postcards.value = mockPostcards
    saveToStorage()
  }

  return {
    travels,
    postcards,
    isLoading,
    error,
    sortedTravels,
    sortedPostcards,
    currentTravel,
    initData,
    loadFromStorage,
    getTravelById,
    getPostcardById,
    getPostcardsByTravel,
    addTravel,
    updateTravel,
    addPostcard,
    updatePostcard,
    toggleFavorite,
    deleteTravel,
    deletePostcard,
    clearError,
    resetData,
  }
})
