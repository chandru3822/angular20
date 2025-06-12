<template>
  <div class="proposal-document-skeleton">
    <!-- Header card with proposal number and buttons -->
    <v-card
      width="100vw"
      class="rounded-0 prop-view-card"
      elevation="4"
    >
      <span class="d-flex align-center">
        <FormFieldSkeleton
          type="text"
          width="200"
          custom-class="config-label"
        />
      </span>
      <v-spacer />
      <div class="prop-button-group">
        <FormFieldSkeleton
          v-for="i in 3"
          :key="`action-button-${i}`"
          type="button"
          width="90"
          :custom-class="i < 3 ? 'mr-2' : ''"
        />
      </div>
    </v-card>

    <!-- Proposal document viewer skeleton -->
    <v-card
      class="pt-4 proposal-container proposal-viewer skeleton-viewer"
    >
      <!-- Simulated document pages -->
      <div class="proposal-zoom-lock skeleton-pages">
        <!-- Page skeleton -->
        <v-skeleton-loader
          v-for="i in 3"
          :key="`page-skeleton-${i}`"
          type="card"
          :height="1056"
          :width="816"
          class="mx-auto"
        ></v-skeleton-loader>
      </div>
    </v-card>

    <!-- Page selector skeleton -->
    <v-card class="rounded-0 proposal-actions">
      <div class="text-center max-width">
        <FormFieldSkeleton
          type="text"
          width="120"
          custom-class="mx-auto"
        />
      </div>
    </v-card>
  </div>
</template>

<script setup>
import FormFieldSkeleton from './FormFieldSkeleton.vue'
</script>

<style scoped lang="scss">
.proposal-document-skeleton {
  .prop-view-card {
    display: flex;
    padding: 14px 18px;
    font-size: 20px;
    align-content: center;
  }

  .config-label {
    font-size: 20px;
  }

  .prop-button-group {
    display: flex;
    justify-content: flex-end;
    margin-right: 4px;
  }

  .skeleton-viewer {
    padding-left: 16px;
    height: calc(
      100vh - var(--padding-and-margins) - var(--dirty-cfv-height) - var(
        --proposal-action-height
      )
    );
    border-radius: 0;
    overflow-y: auto;
    background-color: var(--v-grey-lighten4);
  }

  .skeleton-pages {
    transform-origin: center;

    @media (min-width: 1548px) {
      transform-origin: top center;
    }

    @media (max-width: 600px) {
      --scale: 0.45;
    }
  }

  .proposal-actions {
    height: var(--proposal-action-height);
    border: solid 1px var(--v-grey-lighten3);
    background-color: var(--v-grey-lighten4);
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
  }
}
</style>
