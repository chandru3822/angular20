<template>
<v-container class="pa-0">
  <v-toolbar flat color="transparent">
    <div class=" headline-small"><v-icon class="show-xs" @click="openMenu()">mdi-menu</v-icon>{{pageName}} Overview</div>
    <v-spacer></v-spacer>
    <v-toolbar-items>
      <v-btn
        text x-small color="primary"
        @click.stop="$emit('clickEdit')"
        v-if="showEditBtn">
        <v-icon>edit</v-icon>
      </v-btn>
    </v-toolbar-items>
  </v-toolbar>
  <div class="mx-4" v-if="details">
    <div v-for="detail in details">
      <div v-if="!detail.type || detail.type === constants.OVERVIEW_FIELD_TYPES.DEFAULT" class="mb-2">
        <span class="detail-label label-small">{{detail.label}}: </span>
        <div v-if="detail.value" @click="detail.clickable ? $emit(`click-detail`, detail) : null"
              class="detail-item body-medium body-medium"
              :class="{'clickable underline anchor':detail.clickable}" >
          {{detail.value}}
        </div>
        <div v-else class="detail-item body-medium body-medium">N/A</div>
      </div>
      <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.DATE" class="mb-4">
        <span class="detail-label label-small">{{detail.label}}: </span><br/>
        <span v-if="detail.value" class="detail-item body-medium">{{formatDate(detail.value)}}</span>
        <span v-else class="d-inline-block detail-item body-medium">N/A</span>
      </div>
      <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.STATUS" :class="{'mb-4': !dense, 'mb-0': dense}">
        <span class="vertical-top detail-label label-small">{{detail.label}}: </span><br/>
        <span class="d-inline-block detail-item vertical-top body-medium"
              v-if="detail.value"
              :class="[getStatusColorClass(detail.statusTypeId), {'status-active': detail.active && !detail.statusTypeId,'status-cancelled': !detail.active && !detail.statusTypeId}]">
        {{detail.value}}
        <span v-if="detail.statusType">({{detail.statusType}})</span>
        </span>
      </div>
      <div v-if="!detail.type || detail.type === constants.OVERVIEW_FIELD_TYPES.ID" class="flex-display mb-2 clickable" @click="copyToClipBoard(detail.value, detail.label)">
        <span class="detail-label label-small pr-2"><v-icon small>mdi-information</v-icon></span>
        <span v-if="detail.value" class="detail-item body-medium body-medium">
          {{detail.value}}
          <v-tooltip right>
            <template v-slot:activator="{on, attrs}">
              <v-icon small color="primary" v-bind="attrs" v-on="on">mdi-content-copy</v-icon>
            </template>
            <span>Copy</span>
          </v-tooltip>
        </span>
      </div>
      <div v-if="!detail.type || detail.type === constants.OVERVIEW_FIELD_TYPES.EMAIL" class="flex-display mb-2" :class="{'clickable':!!detail.value}" @click="copyToClipBoard(detail.value, detail.label)">
        <span class="detail-label label-small pr-2"><v-icon small>mdi-email</v-icon></span>
        <span v-if="detail.value" @click="detail.clickable ? $emit(`click-detail`, detail) : null"
              class="detail-item body-medium body-medium"
              :class="{'clickable underline anchor':detail.clickable}" >
          {{detail.value}}
        </span>
      </div>

      <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.ADDRESS" class="flex-display mb-2" :class="{'clickable':!!detail.value}" @click="copyToClipBoard(`${detail.value.street} ${detail.value.city}, ${detail.value.state} ${detail.value.zip}`, detail.label)">
          <span class="detail-label label-small pr-2"><v-icon small>mdi-map-marker</v-icon></span>
          <div v-if="detail.value && (detail.value.street || detail.value.city || detail.value.state || detail.value.zip)" class="d-inline-block vertical-top detail-item body-medium">
            <span>{{detail.value.street}}</span><br/>
            <span>{{detail.value.city}}, {{detail.value.state}} {{detail.value.zip}}</span>
          </div>
        <span v-else class="d-inline-block detail-item body-medium">N/A</span>
      </div>
      <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.PHONE" class="flex-display mb-2" :class="{'clickable':!!detail.value}" @click="copyToClipBoard(detail.value, detail.label)">
        <span class="detail-label label-small pr-2"><v-icon small>mdi-phone</v-icon></span>
        <span v-if="detail.value" class="detail-item body-medium">{{formatPhoneNumber(detail.value)}}</span>
        <span v-else class="d-inline-block detail-item body-medium">N/A</span>
      </div><div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.EXTENSION" class="flex-display mb-2" :class="{'clickable':!!detail.value}" @click="copyToClipBoard(detail.value, detail.label)">
        <span class="detail-label label-small pr-2">
          <v-tooltip top>
            <template v-slot:activator="{on, attrs}">
              <v-icon small v-bind="attrs" v-on="on">mdi-pound</v-icon>
            </template>
            <span>phone extension</span>
          </v-tooltip>
        </span>
        <span v-if="detail.value" class="detail-item body-medium">{{detail.value}}</span>
        <span v-else class="d-inline-block detail-item body-medium">N/A</span>
      </div>
      <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.MOBILE_PHONE" class="flex-display mb-2" :class="{'clickable':!!detail.value}" @click="copyToClipBoard(detail.value, detail.label)">
        <span class="detail-label label-small pr-2">
          <v-icon small>mdi-cellphone</v-icon>
        </span>
        <span v-if="detail.value" class="detail-item body-medium">{{formatPhoneNumber(detail.value)}}</span>
        <span v-else class="d-inline-block detail-item body-medium">N/A</span>
      </div>
      <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.BUTTON" class="mb-4">
        <div class="mt-3">
          <v-btn outlined small color="primary" class="label-medium text-transform-unset px-3 py-1" :to="`/contact/${detail.value}`" target="_blank">Go to contact<v-icon small class="pl-2">mdi-open-in-new</v-icon></v-btn>
        </div>
      </div>
      <div v-if="detail.type === constants.OVERVIEW_FIELD_TYPES.OWNER" :class="{'flex-display': !detail.value}">
        <span class="detail-label label-small">{{detail.label}}:</span>
        <div v-if="detail.value" class="d-inline-block detail-item body-medium" @dblclick="selectValue">
                <span :class="{'error-text': !detail.value.hasAccess}">{{
                    detail.value.fullName
                  }} - {{detail.value.position }} <br/></span>
          <span v-if="detail.value.hasAccess">{{ formatPhoneNumber(detail.value.phoneNumber) }}<br/></span>
        </div>
        <span v-else class="d-inline-block detail-item body-medium pl-2">N/A</span>
      </div>
    </div>
  </div>
</v-container>
</template>

<script>
import {formatPhoneNumber, getSnackbar} from "../../helpers/helpers";
import constants from "../../helpers/constants"
import {getStatusColorClass} from "../../services/projectStatusTypeService";
import {AppMutations} from "../../stores/AppStore";

export default {
  name: "PageOverview",
  props: {
    pageName: String,
    showEditBtn: Boolean,
    dense: {
      type: Boolean,
      default: false
    },
    details: Array,
    owner: Object
  },
  data() {
    return {
      constants,
      formatPhoneNumber,
      getStatusColorClass
    }
  },
  methods: {
    formatDate(value){
      return this.$filters.formatDate(value, 'date')
    },
    copyToClipBoard(textValue, label){
      if(textValue) {
        if(!label){
          label = 'text'
        }
        navigator.clipboard.writeText(textValue);
        this.snackbar = getSnackbar('SUCCESS', `Copied ${label} to clipboard`)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    selectValue(){

    },
    openMenu(){
      this.$store.state.project.leftSideSplit = false;
    },
   }
}
</script>

<style lang="scss" scoped>
.detail-label {
  color: var(--v-grey-darken1);
}

.detail-item {
  //font-size: 0.875rem;
  //margin-left: 5px;
  //overflow-wrap: break-word;
  overflow-wrap: anywhere;
}

.text-transform-unset {
  text-transform: unset;
}

.vertical-top {
  margin-top: -2px;
}
</style>
