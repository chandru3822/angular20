<template>
  <v-btn
      v-if="actionResult.actionTypeId === 2 && !actionResult.hideFromWeb"
    :disabled="!canPerformAction"
    color="primary"
    class="action-button"
    @click="[canPerformAction = false, completeAction(actionResult)]"
  >
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
</v-btn>
  <v-btn class="multi-link-button"
      v-else-if="actionResult.actionTypeId === 1 && !actionResult.hideFromWeb"
      @click="followMultipleLinks(actionResult)"
  >
    {{ actionResult.actionName }}
  </v-btn>
</template>

<script>

export default {
  name: 'ActionButton',
  props: {
    actionResult: Object,
    canPerformAction: Boolean,
    completeAction: Function,
    followMultipleLinks: Function
  },
  methods: {
    getColor () {
      return this.canPerformAction ? 'white' : null
    },
  }
}
</script>

<style lang="scss">
.action-button > .v-btn__content {
  color: white !important;
  text-transform: none;
}
.multi-link-button > .v-btn__content {
  color: var(--v-primary-base) !important;
}
</style>
