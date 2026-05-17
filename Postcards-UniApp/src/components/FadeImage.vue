<template>
  <view class="fade-img-wrap" :style="wrapStyle">
    <image
      :src="src"
      :mode="mode"
      :lazy-load="lazyLoad"
      class="fade-img"
      :class="{ loaded: loaded }"
      @load="onLoad"
      @error="onError"
    />
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const props = defineProps<{
  src: string
  mode?: string
  lazyLoad?: boolean
  bgColor?: string
  aspectRatio?: string
}>()

const loaded = ref(false)
const error = ref(false)

const wrapStyle = computed(() => {
  const style: Record<string, string> = {}
  if (props.bgColor) style.backgroundColor = props.bgColor
  if (props.aspectRatio) style.aspectRatio = props.aspectRatio
  return style
})

function onLoad() {
  loaded.value = true
}

function onError() {
  error.value = true
  loaded.value = true
}
</script>

<style scoped>
.fade-img-wrap {
  width: 100%;
  height: 100%;
  background-color: #E8E4DC;
  overflow: hidden;
}
.fade-img {
  width: 100%;
  height: 100%;
  opacity: 0;
  transition: opacity 0.35s ease;
}
.fade-img.loaded {
  opacity: 1;
}
</style>
