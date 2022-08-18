<template>
<v-container class="pa-0">
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
  <div class="mx-4" v-if="details">
    <div v-for="detail in details">
      <div v-if="!detail.type || detail.type === constants.OVERVIEW_FIELD_TYPES.DEFAULT">
        <span class="detail-label">{{detail.label}}: </span>
        <span v-if="detail.value" @click="detail.clickable ? $emit(`click-detail`, detail) : null"
              class="detail-item"
              :class="{'clickable underline primary--text text--lighten-1':detail.clickable}" >
          {{detail.value}}
        </span>
      </div>
      <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.DATE">
        <span class="detail-label">{{detail.label}}: </span>
        <span v-if="detail.value" class="detail-item">{{formatDate(detail.value)}}</span>
      </div>
      <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.STATUS">
        <span class="vertical-top detail-label">{{detail.label}}: </span>
        <span class="d-inline-block detail-item vertical-top"
              v-if="detail.value"
              :class="{'status-active': detail.active,'status-cancelled': !detail.active}">
        {{detail.value}}
        <br/>
        <span v-if="detail.statusType">({{detail.statusType}})</span>
        </span>
      </div>
      <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.ADDRESS">
          <span class=" vertical-top detail-label">{{detail.label}}: </span>
          <div v-if="detail.value" class="d-inline-block vertical-top detail-item">
            <span>{{detail.value.street}}</span><br/>
            <span>{{detail.value.city}}, {{detail.value.state}} {{detail.value.zip}}</span>
          </div>
      </div>
      <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.PHONE">
          <span class="detail-label">{{detail.label}}: </span>
          <span v-if="detail.value" class="detail-item">{{formatPhoneNumber(detail.value)}}</span>
      </div>
      <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.OWNER" class="mt-2">
        <span class="vertical-top detail-label">{{detail.label}}:</span>
        <div v-if="detail.value" class="d-inline-block detail-item vertical-top">
                <span :class="{'error-text': !detail.value.hasAccess}">{{
                    detail.value.fullName
                  }} - {{detail.value.position }} <br/></span>
          <span v-if="detail.value.hasAccess">{{ formatPhoneNumber(detail.value.phoneNumber) }}<br/></span>
        </div>
      </div>
    </div>
  </div>
</v-container>
</template>

<script>
import {formatPhoneNumber} from "../../helpers/helpers";
import constants from "../../helpers/constants"

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
      constants,
      formatPhoneNumber
    }
  },
   methods: {
    formatDate(value){
      return this.$filters.formatDate(value, 'date')
    }
   }
}
</script>

<style lang="scss" scoped>
.detail-label {
  font-size: 12px;
  color: var(--v-grey-darken1);
}

.detail-item {
  font-size: 0.875rem;
  margin-left: 5px;
  overflow-wrap: break-word;
}

.vertical-top {
  margin-top: -2px;
}
</style>
