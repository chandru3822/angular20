<template>
  <div id="status-checkbox" style="z-index: 1000">
    <v-checkbox
        v-if="!cancelled"
        :label="fieldName"
        color="success lighten-1"
        :ripple="false"
        readonly
        hide-details
        v-model="field.fieldValue"
        class="default-text-color d-inline-block body-large milestone-checkbox"
    >
      <template v-slot:label>
        <span class="milestone-checkbox-label"
              :class="{'milestone-completed': field.fieldValue != null}">{{fieldName}}</span>
      </template>
    </v-checkbox>

    <v-checkbox
        v-else
        :label="fieldName"
        color="grey-base"
        :ripple="false"
        readonly
        hide-details
        v-model="field.fieldValue"
        class="default-text-color d-inline-block body-large milestone-checkbox"
    />
    <!--    <div v-if="field.fieldValue != null" class="d-inline-block ml-3 body-large">-->
    <!--      &lt;!&ndash;        i dont think we have to handle ALL data types here. just the common ones, data view fields are pretty normalized &ndash;&gt;-->
    <!--      <span v-if="field.dataTypeId === 1">{{field.fieldValue | formatDate('date', 'D MMM YYYY')}}</span>-->
    <!--      <span v-else-if="field.dataTypeId === 2">{{field.fieldValue | formatDate('timestamp', 'D MMM YYYY H:mm a')}}</span>-->
    <!--      <span v-else>{{field.fieldValue}}</span>-->
    <!--    </div>-->
  </div>
</template>

<script setup>

import {getRequest,  handleHidingGlobalLoader, logError} from '@/helpers/helpers'
import constants from "@/helpers/constants";
import SpinnerInline from '@/components/SpinnerInline'
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const props = defineProps({
  field: Object,
  cancelled: Boolean
})
const { field, cancelled } = toRefs(props)

const fieldName  = ref("")

onMounted(() => {
  if(field.value.fieldValue == null){
    fieldName.value = field.value.fieldName;
  }
  else {
    if (field.value.dataTypeId === 1) {
      //dataTypeId: 1 = date
      fieldName.value = field.value.fieldName + ': ' + new Date(field.value.fieldValue).toLocaleDateString('en-US', {
        timeZone: 'UTC',
        day: 'numeric', month: 'short', year: 'numeric' //formatDate('date', 'D MMM YYYY');
      })
    } else if (field.value.dataTypeId === 2) {
      //dataTypeId: 2 = timestamp
      fieldName.value = field.value.fieldName + ': ' + new Date((field.value.fieldValue + 'Z')).toLocaleDateString('en-US', {
        day: 'numeric', month: 'long', year: 'numeric', hour: "numeric", minute: "2-digit", hourCycle: "h12" //formatDate('date', 'D MMM YYYY');
      })//formatDate('timestamp', 'D MMM YYYY H:mm a');
    } else {
      fieldName.value = field.value.fieldName + ': ' + field.value.fieldValue;
    }
  }
})

</script>

<style lang="scss" scoped>
.body-large{
  color: #000000 !important;
  font-family: lato !important;
  font-weight: 400 !important;
  line-height: 1.563rem !important;
  font-size: 1rem !important;
  @media (min-width: 960px) {
    line-height: 1.6;  }
}

</style>

<style lang="scss">
#status-checkbox .mdi-checkbox-blank-outline {
  color: var(--v-grey-base);
}

#status-checkbox input:hover{
  cursor: default !important;
}

#status-checkbox label:hover{
  cursor: default !important;
}

#status-checkbox:hover{
  cursor: default !important;
}

#status-checkbox .v-label{
  font-family: lato;
  font-weight: 400;
  line-height: 1.563rem;
  font-size: 1rem;
  color: #000000 !important;
}

#status-checkbox .v-input__slot:hover{
  cursor: default !important;

}
#status-checkbox :hover{
  cursor: default !important;

}

.milestone-checkbox-label {
  color: var(--v-grey-darken1);
}

.milestone-completed{
  color: var(--v-grey-darken4);
}

.milestone-checkbox{
  margin-top: 10px;
}

</style>
