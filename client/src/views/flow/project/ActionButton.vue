<template>
  <a-btn
      v-if="actionResult.actionTypeId === 2 && !actionResult.hideFromWeb"
      :disabled="!canPerformAction"
      color="primary"
      class="action-button"
      @click="completeAction(actionResult)">
    <template v-slot:default>
      <div>
        <div class="action-button-name">
          {{ actionResult.actionName }}
        </div>
        <div class="action-button-subtitle">
                  <span class="action-button-subtitle-date">{{
                      actionResult.actionRunDate | formatDate('timestamp', 'M/D/YY h:mm a')
                    }}</span>
          {{ actionResult.actionRunBy }}
        </div>
      </div>
      <v-icon :color="getColor()" v-if="actionResult.alreadyTriggered" class="ml-1" size="20">check</v-icon>
      <v-icon v-if="actionResult.triggerAutomatically">mdi-alpha-a</v-icon>
    </template>
  </a-btn>
  <a-btn
      class="multi-link-button"
      v-else-if="actionResult.actionTypeId === 1 && !actionResult.hideFromWeb"
      @click="followMultipleLinks(actionResult)"
      color="unset"
      :text="actionResult.actionName"
  ></a-btn>
</template>

<script setup>

import {toRefs} from 'vue'

const props = defineProps({
  actionResult: Object,
  canPerformAction: Boolean,
  completeAction: Function,
  followMultipleLinks: Function
})
const { actionResult, canPerformAction, completeAction, followMultipleLinks } = toRefs(props)

const getColor = () => {
  return canPerformAction.value ? 'white' : null
}
</script>

<style lang="scss">
.action-button > .v-btn__content {
  color: var(--grey-lighten2);
  text-transform: none;
  //the next two lines allow the button text to wrap on mobile when names are very long
  white-space: normal;
  flex: auto;
}
button.multi-link-button > .v-btn__content {
  color: var(--v-primary-base) !important;
  //the next two lines allow the button text to wrap on mobile when names are very long
  white-space: normal;
  flex: auto;
}

</style>
