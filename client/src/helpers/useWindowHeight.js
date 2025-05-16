import { ref, computed, onMounted, onUnmounted } from 'vue';

export function useWindowHeight(offset = 0) {
  const windowHeight = ref(window.innerHeight);

  const updateWindowHeight = () => {
    windowHeight.value = window.innerHeight;
  };

  const adjustedHeight = computed(() => windowHeight.value - offset);

  onMounted(() => {
    window.addEventListener('resize', updateWindowHeight);
  });

  onUnmounted(() => {
    window.removeEventListener('resize', updateWindowHeight);
  });

  return {
    adjustedHeight
  };
}
