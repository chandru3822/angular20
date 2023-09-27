<template>
  <v-container class="pa-0" id="three-column-container">
  <v-row>
    <slot name="header">
      <v-toolbar v-if="!headerHidden" flat class="three-column-header px-4">
        <v-toolbar-title class="headline-medium d-flex align-center mr-6">
          <slot name="back-btn"></slot>
          {{ headerText }}
        </v-toolbar-title>
        <slot name="search"></slot>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <slot name="header-btn">
          </slot>
        </v-toolbar-items>
      </v-toolbar>
    </slot>
  </v-row>
  <v-row class="pa-6">
    <v-btn small text color="primary" @click="collapseSide('left')">
      <v-icon>mdi-menu</v-icon>
    </v-btn>
  </v-row>
  </v-container>
</template>

<script>

export default {
  name: "ThreeColumnLayoutMobile",
  props: {
    headerText: String,
    headerBtnText: String,
    headerHidden: Boolean,
  }
}
</script>

<style scoped lang="scss">
#three-column-container {
  width: 100%;
  height: 100%;
  max-height: 100% !important;
  padding: 0 !important;
  overflow: hidden;
}

.three-column-header {
  height: 64px;
  background-color: var(--v-grey-lighten2) !important;
}
</style>
