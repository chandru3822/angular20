<template>
  <v-container class="pa-0">
    <v-row>
      <v-col cols="12">
        <div>
          <v-app-bar dense tabs color="white" class="elevation-1">
            <v-tabs
              :optional="true"
              color="primary"
              background-color="white"
              v-model="activeTabIndex"
              slider-color="primary"
            >
              <v-tab
                v-for="(tab, index) in displayedTabs"
                :key="index"
                :to="tab.path"
              >
                {{tab.label}}
              </v-tab>
            </v-tabs>
          </v-app-bar>
          <router-view></router-view>
        </div>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
  import { computed, ref, onMounted, watch } from 'vue'
  import { useUserStore } from '@/stores/UserStore.js'
  import { useBrsStore } from "@/stores/BrsStore.js"
  import { storeToRefs } from 'pinia'
  import { useRouter, useRoute } from 'vue-router/composables'

  const userStore = useUserStore()
  const brsStore = useBrsStore()
  const { commissionPositionId } = storeToRefs(brsStore)
  const router = useRouter()
  const route = useRoute()
  const activeTabIndex = ref(0)
  const previousPositionId = ref(null)

  const isDealerPosition = computed(() => {
    return commissionPositionId.value === 743 || commissionPositionId.value === 828
  })

  const hasDealerFeature = computed(() => {
    return userStore.userHasFeature('COMMISSIONS_INSTALLATION_PARTNER') ||
      userStore.userHasFeature('COMMISSIONS_DEALER')
  })

  const hasCloserFeature = computed(() => {
    return userStore.userHasFeature('COMMISSIONS_CLOSER') ||
      userStore.userHasFeature('COMMISSIONS_SETTER')
  })

  // Make tab definitions reactive by using computed properties
  const closerTabs = computed(() => [
    {
      label: 'Current Payroll',
      path: `/commissionManagement/accounting/current`,
      display: hasCloserFeature.value && !isDealerPosition.value
    }, {
      label: 'Summary',
      path: `/commissionManagement/accounting/summary`,
      display: hasCloserFeature.value && !isDealerPosition.value
    }
  ])

  const dealerTabs = computed(() => [
    {
      label: 'Current Partner Pay',
      path: `/commissionManagement/accounting/partnerPay`,
      display: hasDealerFeature.value && isDealerPosition.value
    }, {
      label: 'Partner Summary',
      path: `/commissionManagement/accounting/partnerSummary`,
      display: hasDealerFeature.value && isDealerPosition.value
    }
  ])

  const tabs = computed(() => {
    return isDealerPosition.value ? dealerTabs.value : closerTabs.value
  })

  const displayedTabs = computed(() => {
    return tabs.value.filter(tab => tab.display)
  })

  const findTabIndexByPath = (path) => {
    return displayedTabs.value.findIndex(tab => path.includes(tab.path))
  }

  const navigateToTab = (index) => {
    if (displayedTabs.value[index]) {
      router.push({
        path: displayedTabs.value[index].path,
      })
    }
  }

  const setActiveTab = () => {
    // Get the current route path
    const currentPath = route.path

    // Find the matching tab
    const matchedTabIndex = findTabIndexByPath(currentPath)

    // Set the active tab model or navigate to first tab if no match
    if (matchedTabIndex !== -1) {
      activeTabIndex.value = matchedTabIndex
    } else {
      // If no match found, redirect to the first available tab
      navigateToTab(0)
    }
  }

  // Initialize component
  onMounted(() => {
    previousPositionId.value = commissionPositionId.value
    setActiveTab()
  })

  // Watch for route changes to update the active tab
  watch(
    () => route.path,
    () => {
      setActiveTab()
    }
  )

  // Watch for active tab changes - needed for direct tab clicks
  watch(activeTabIndex, (newIndex) => {
    if (displayedTabs.value[newIndex]) {
      const currentPath = route.path
      const targetPath = displayedTabs.value[newIndex].path

      // Only navigate if not already on that path
      if (!currentPath.includes(targetPath)) {
        router.push({
          path: targetPath,
        })
      }
    }
  })

  // Watch for changes in the displayed tabs and reset to first tab if needed
  watch(displayedTabs, (newTabs) => {
    if (newTabs.length > 0 && activeTabIndex.value >= newTabs.length) {
      // If current tab index is out of bounds, reset to the first tab
      navigateToTab(0)
    }
  }, { deep: true })
</script>

<style lang="scss" scoped>
  .v-data-table {
    border-radius: 0;
  }
</style>
