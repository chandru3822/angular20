<template>
<v-container>
  <v-toolbar flat color="transparent">
    <v-toolbar-title class="albatross-header-3">{{pageName}} Overview</v-toolbar-title>
    <v-spacer></v-spacer>
    <v-toolbar-items>
      <v-btn
        text x-small color="primary"
        @click="$emit('clickEdit')"
        v-if="showEditBtn">
        <v-icon>edit</v-icon>
      </v-btn>
    </v-toolbar-items>
  </v-toolbar>
  <div class="mx-4">
    <div v-for="detail in details">
      <span class="detail-label">{{detail.label}}: </span>
      <span class="detail-item">{{detail.value}}</span> <br/>
    </div>
    <div v-if="owner" class="mt-2">
      <span class="vertical-top detail-label">Owner:</span>
      <div class="d-inline-block detail-item">
                <span :class="{'error-text': owner.hasAccess}">{{
                    owner.fullName
                  }} - {{owner.position }} <br/></span>
        <span v-if="owner.hasAccess">{{ formatPhoneNumber(owner.phoneNumber) }}<br/></span>
      </div>
    </div>
  </div>
</v-container>
</template>

<script>
import {formatPhoneNumber} from "../../helpers/helpers";

export default {
  name: "PageOverview",
  props: {
    pageName: String,
    showEditBtn: Boolean,
    details: Array,
    owner: Object
  },
  data() {
    return {
      formatPhoneNumber
    }
  }
}
</script>

<style lang="scss" scoped>
.detail-label {
  font-size: 12px;
  color: var(--v-grey-darken2);
}

.detail-item {
  font-size: 0.875rem;
  margin-left: 5px;
  overflow-wrap: break-word;
}
</style>
